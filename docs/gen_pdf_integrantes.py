"""Gera docs/entrega-integrantes.pdf a partir dos dados abaixo.

Fonte simples e editável do PDF obrigatório da entrega (só nomes/RM dos
integrantes + link do GitHub + link do YouTube — nada além disso).

Uso:
    python -m pip install fpdf2
    python docs/gen_pdf_integrantes.py

Antes de gerar o PDF final, atualize GITHUB_LINK e YOUTUBE_LINK abaixo.
"""

from fpdf import FPDF

INTEGRANTES = [
    "Pedro Vaz Ferreira - RM566551",
    "João Victor Luiz Oliveira Resende - RM565139",
    "Vitor Dias dos Santos - RM565422",
    "Felipe Kirschner Modesto - RM561810",
]

GITHUB_LINK = "https://github.com/PET-FAMILYY/PET-FAMILY-CLOUD"
YOUTUBE_LINK = "https://youtu.be/qz70Rx8wwx8"

OUTPUT_PATH = "docs/entrega-integrantes.pdf"


def gerar_pdf() -> None:
    pdf = FPDF(format="A4")
    pdf.set_auto_page_break(auto=True, margin=25)
    pdf.add_page()
    pdf.set_margins(25, 25, 25)

    pdf.set_font("Helvetica", "B", 12)
    pdf.cell(0, 10, "Integrantes", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 11)
    for nome in INTEGRANTES:
        pdf.cell(0, 8, f"- {nome}", new_x="LMARGIN", new_y="NEXT")

    pdf.ln(8)
    pdf.set_font("Helvetica", "B", 12)
    pdf.cell(0, 10, "Link do repositório GitHub", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 11)
    pdf.cell(0, 8, GITHUB_LINK, new_x="LMARGIN", new_y="NEXT")

    pdf.ln(8)
    pdf.set_font("Helvetica", "B", 12)
    pdf.cell(0, 10, "Link do vídeo no YouTube", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 11)
    pdf.cell(0, 8, YOUTUBE_LINK, new_x="LMARGIN", new_y="NEXT")

    pdf.output(OUTPUT_PATH)
    print(f"PDF gerado em {OUTPUT_PATH}")


if __name__ == "__main__":
    gerar_pdf()
