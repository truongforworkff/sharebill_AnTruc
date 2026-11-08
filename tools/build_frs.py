from pathlib import Path
import re
from docx import Document
from docx.shared import Pt, RGBColor
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
root=Path(__file__).resolve().parents[1]
doc=Document(root/'docs/Share_Bill_FRS_v0.2.docx')
for el in list(doc._element.body):
    if el.tag!=qn('w:sectPr'): doc._element.body.remove(el)
for name in ['Normal','Title','Subtitle','Heading 1','Heading 2','Heading 3']:
    style=doc.styles[name];style.font.color.rgb=RGBColor(0,0,0)
    style.font.name='Arial'
    if style.element.rPr is not None:
        for color in style.element.rPr.findall(qn('w:color')):
            for a in ['themeColor','themeTint','themeShade']:color.attrib.pop(qn('w:'+a),None)
doc.styles['Normal'].paragraph_format.space_after=Pt(6)
doc.styles['Normal'].paragraph_format.line_spacing=1.08
doc.styles['Heading 1'].paragraph_format.page_break_before=True
doc.styles['Heading 1'].paragraph_format.space_after=Pt(12)
doc.styles['Heading 2'].paragraph_format.keep_with_next=True
doc.styles['Heading 2'].paragraph_format.space_before=Pt(16)
doc.styles['Heading 2'].paragraph_format.space_after=Pt(8)
for section in doc.sections:
    for p in section.header.paragraphs:
        if p.text:p.text='Share Bill   |   Đặc tả chức năng   |   Phiên bản 0.4'
    for p in section.footer.paragraphs:
        for r in p.runs:r.text=r.text.replace('0.2','0.4')
lines=(root/'docs/FRS.md').read_text().splitlines()
headings=[line[3:] for line in lines if line.startswith('## ')]
bookmarks={h:f'section_{i}' for i,h in enumerate(headings)}
def inline(p,text):
    for i,chunk in enumerate(re.split(r'\*\*(.*?)\*\*',text)):
        r=p.add_run(chunk);r.bold=bool(i%2)
def bookmark(p,name,index):
    a=OxmlElement('w:bookmarkStart');a.set(qn('w:id'),str(index));a.set(qn('w:name'),name)
    z=OxmlElement('w:bookmarkEnd');z.set(qn('w:id'),str(index));p._p.insert(0,a);p._p.append(z)
def toc():
    p=doc.add_paragraph('Mục lục','Heading 1');p.paragraph_format.page_break_before=False
    for h in headings:
        p=doc.add_paragraph();p.paragraph_format.space_after=Pt(7)
        link=OxmlElement('w:hyperlink');link.set(qn('w:anchor'),bookmarks[h])
        r=OxmlElement('w:r');text=OxmlElement('w:t');text.text=h;r.append(text);link.append(r);p._p.append(link)
    doc.add_paragraph('Bấm tên mục để chuyển đến nội dung. Dùng ngăn Điều hướng của Word để mở từng phân hệ.')
def table(rows):
    t=doc.add_table(rows=1, cols=len(rows[0]));t.alignment=WD_TABLE_ALIGNMENT.CENTER;t.autofit=False
    # Keep the short ID column narrow, with room for descriptive requirements.
    widths=([0.13,0.40,0.47] if len(rows[0])==3 else [0.28,0.72])
    total=doc.sections[0].page_width-doc.sections[0].left_margin-doc.sections[0].right_margin
    for col,f in zip(t.columns,widths):col.width=int(total*f)
    for idx,row in enumerate(rows):
        cells=t.rows[0].cells if idx==0 else t.add_row().cells
        trPr=t.rows[idx]._tr.get_or_add_trPr()
        if idx==0:
            repeat=OxmlElement('w:tblHeader');trPr.append(repeat)
        cant=OxmlElement('w:cantSplit');trPr.append(cant)
        for j,(cell,txt) in enumerate(zip(cells,row)):
            cell.width=int(total*widths[j]);cell.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
            p=cell.paragraphs[0];p.paragraph_format.space_after=Pt(4);p.paragraph_format.space_before=Pt(4);p.paragraph_format.line_spacing=1.05
            inline(p,txt)
            for r in p.runs:r.font.size=Pt(9.5);r.font.color.rgb=RGBColor(255,255,255) if idx==0 else RGBColor(0,0,0);r.bold=True if idx==0 else r.bold
            tcPr=cell._tc.get_or_add_tcPr()
            shade=OxmlElement('w:shd');shade.set(qn('w:fill'),'263D4A' if idx==0 else ('F2F5F7' if idx%2==0 else 'FFFFFF'));tcPr.append(shade)
            mar=OxmlElement('w:tcMar')
            for side in ['top','left','bottom','right']:
                e=OxmlElement('w:'+side);e.set(qn('w:w'),'90');e.set(qn('w:type'),'dxa');mar.append(e)
            tcPr.append(mar)
            borders=OxmlElement('w:tcBorders')
            for side in ['top','left','bottom','right']:
                e=OxmlElement('w:'+side);e.set(qn('w:val'),'single');e.set(qn('w:sz'),'4');e.set(qn('w:color'),'D9D9D9');borders.append(e)
            tcPr.append(borders)
    p=doc.add_paragraph();p.paragraph_format.space_after=Pt(0);p.paragraph_format.space_before=Pt(0);p.paragraph_format.line_spacing=Pt(1);p.add_run().font.size=Pt(1)
i=0;inserted=False
while i<len(lines):
    line=lines[i]
    if not line.strip():i+=1;continue
    if line.startswith('|'):
        rows=[]
        while i<len(lines) and lines[i].startswith('|'):
            row=[x.strip() for x in lines[i].strip('|').split('|')]
            if not all(re.fullmatch(r'[-: ]+',x) for x in row):rows.append(row)
            i+=1
        table(rows);continue
    if line.startswith('# '):doc.add_paragraph(line[2:],'Title')
    elif line.startswith('## '):
        if not inserted:toc();inserted=True
        h=line[3:];p=doc.add_paragraph(h,'Heading 1');bookmark(p,bookmarks[h],headings.index(h)+1)
    elif line.startswith('### '):doc.add_paragraph(line[4:],'Heading 2')
    elif line.startswith('- '):inline(doc.add_paragraph(style='List Bullet'),line[2:])
    else:inline(doc.add_paragraph(),line)
    i+=1
out=root/'docs/Share_Bill_FRS_v0.4.docx';doc.save(out);print(out)
