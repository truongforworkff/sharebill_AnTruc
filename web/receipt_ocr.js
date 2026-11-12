// Pinned Tesseract.js runs in a local worker. Only engine/model files are fetched;
// the selected bill stays in the browser and is never sent to an OCR server.
window.chungReadReceipt = async (base64) => {
  let worker;
  let cancelled = false;
  let timer;
  const run = async () => {
    try {
      const { default: Tesseract } = await import('https://cdn.jsdelivr.net/npm/tesseract.js@6.0.1/dist/tesseract.esm.min.js');
      worker = await Tesseract.createWorker(['vie', 'eng'], 1, {
        workerPath: 'https://cdn.jsdelivr.net/npm/tesseract.js@6.0.1/dist/worker.min.js',
        corePath: 'https://cdn.jsdelivr.net/npm/tesseract.js-core@6.0.0',
        langPath: 'https://tessdata.projectnaptha.com/4.0.0',
      });
      if (cancelled) throw new Error('OCR timed out');
      const bytes = Uint8Array.from(atob(base64), (c) => c.charCodeAt(0));
      const { data } = await worker.recognize(new Blob([bytes]));
      return data.text;
    } finally {
      if (worker) await worker.terminate();
    }
  };
  try {
    return await Promise.race([
      run(),
      new Promise((_, reject) => {
        timer = setTimeout(() => {
          cancelled = true;
          if (worker) worker.terminate();
          reject(new Error('OCR timed out'));
        }, 40000);
      }),
    ]);
  } finally {
    clearTimeout(timer);
  }
};
