import logging
import time
from pathlib import Path
import PyPDF2
from docling.document_converter import DocumentConverter
from docling.datamodel.base_models import InputFormat
from docling.datamodel.pipeline_options import PdfPipelineOptions, TableFormerMode
from docling.document_converter import PdfFormatOption
import torch
import gc

_log = logging.getLogger(__name__)

def process_pdf(input_path: Path, output_path: Path):
    try:
        # Controllo CSV esistente
        csv_path = output_path / f"{input_path.stem}.csv"
        if csv_path.exists():
            _log.info(f"File CSV {csv_path.name} già esistente, skip")
            return

        # Pulizia memoria CUDA
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
            gc.collect()

        # Pipeline setup
        pipeline_options = PdfPipelineOptions(do_table_structure=True)
        pipeline_options.table_structure_options.mode = TableFormerMode.ACCURATE

        doc_converter = DocumentConverter(
            format_options={
                InputFormat.PDF: PdfFormatOption(
                    pipeline_options=pipeline_options,
                    page_numbers=[3]  # Processa solo pagina 3
                )
            }
        )

        _log.info(f"Elaboro pagina 3 di {input_path.name}")

        start_time = time.time()
        conv_res = doc_converter.convert(input_path)

        _log.info(f"Trovate {len(conv_res.document.tables)} tabelle")

        # Salva la prima tabella trovata
        if conv_res.document.tables:
            table = conv_res.document.tables[0]
            table_df = table.export_to_dataframe()
            if not table_df.empty:
                table_df.to_csv(csv_path, index=False)
                _log.info(f"Salvato CSV per {input_path.name}")
            else:
                _log.warning(f"DataFrame vuoto per {input_path.name}")
        else:
            _log.warning(f"Nessuna tabella trovata in {input_path.name}")

    except Exception as e:
        _log.error(f"Errore processando {input_path.name}: {str(e)}", exc_info=True)

def main():
    # Configurazione logging
    logging.basicConfig(level=logging.INFO)

    # Definizione cartelle input e output
    input_dir = Path("/home/aborruso/git/archivioDatiPubbliciPreziosi/docs/omicidiVolontari/pdf/renamed")
    output_dir = Path("/home/aborruso/git/archivioDatiPubbliciPreziosi/docs/omicidiVolontari/pdf/csv")

    # Crea la cartella output se non esiste
    output_dir.mkdir(parents=True, exist_ok=True)

    # Processa tutti i PDF nella cartella
    for pdf_file in input_dir.glob("*.pdf"):
        #if pdf_file.name in ["2022-06-27.pdf", "2022-03-07.pdf","2023-06-05.pdf","2023-10-22.pdf"] or pdf_file.name.startswith("2024"):
        # skip 2021-10-17.pdf, because it seems a wrong file
        if pdf_file.name in ["2021-10-17.pdf"] or pdf_file.name.startswith("2024"):
            _log.info(f"Skipping file {pdf_file.name}")
            continue
        _log.info(f"Elaborazione del file {pdf_file.name}")
        process_pdf(pdf_file, output_dir)

if __name__ == "__main__":
    main()
