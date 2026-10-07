# Member 1: Instacart data understanding and cleaning

This folder contains the executed cleaning notebook, real examples, presentation notes, and five easy before/after charts. All six complete source files were processed.

## Files
- `Instacart_Data_Cleaning.ipynb`: five main steps with executable processing code and actual outputs.
- `Member1_Presentation_Notes.md`: four-slide outline, a short speaking script, and Q&A.
- `figures/`: two cleaning comparisons and three dataset distributions.
- `requirements.txt`: Python dependencies.
- `.gitignore`: excludes the source CSVs and the full generated data package.

## Measured cleaning results
| Topic | Finding and action | Use in the next steps |
| --- | --- | --- |
| Product-name spacing | 424 labels corrected; all 49,688 product IDs retained | Consistent searches and readable names |
| First-order day gaps | 206,209 expected blanks retained as missing; import as SQL NULL | Correct averages of known gaps |
| Complete duplicates and keys | Zero accidental duplicates found across the files and purchase union | Avoid inflated counts |
| Matching names | 37 groups with different IDs retained | Protect valid catalog entries |
| Values and relationships | Valid hours, flags, gaps, cart positions, and references checked | Reliable grouping and joins |

The simplified notebook ran 86 checks successfully. No source records were removed. Dataset distributions are preserved before and after cleaning.

## Dataset and cleaned handoff
- Orders: 3,421,083 from 206,209 customers.
- Products: 49,688; aisles: 134; departments: 21.
- Prior purchase lines: 32,434,489; train purchase lines: 1,384,617.
- Combined supplied purchases: 33,819,106.

The purchase files have the same columns and are combined for the database handoff, preserving every record. `orders.eval_set` still identifies prior/train/test membership. File combination is handoff preparation, not a cleaning correction. For predictive modeling, respect the original split roles.

Five cleaned staging CSVs are generated under `Instacart_Cleaned_Data/tables/`. Products retains its original department reference until Member 2 implements the catalog 3NF design. First-order gap fields are blank in CSV and should become SQL NULL in MySQL. Test basket contents are withheld; those orders are excluded from basket-size statistics.

The cleaned-data ZIP is approximately 206 MB and is shared separately. Attach it to a GitHub Release or use the group's shared file location; add that shared download link to the main project README when available. A chat-only file link is not a public download link for the repository.

## Reproduce
1. Open the notebook from this `member1/` folder.
2. Install the packages in `requirements.txt` in your notebook environment.
3. Put all six original CSV files in `member1/raw_data/`, or let the notebook try its missing-file downloads.
4. Run every cell in order. The full dataset requires a few GB of RAM.
5. Use the generated CSVs, reports, and ZIP. The original files remain unchanged.

Source: https://www.kaggle.com/datasets/psparks/instacart-market-basket-analysis
Data descriptions: https://gist.github.com/jeremystan/c3b39d947d9b88b3ccff3147dbcf6c6b

## Add your contribution through the GitHub website
1. Extract this package and open your group's repository while signed into your own account.
2. Select Add file, then Upload files.
3. Drag the extracted `member1` folder into the upload area. Upload its contents, not the ZIP archive.
4. Enter a commit message such as `Add Member 1 data cleaning notebook and evidence`.
5. Choose a new branch named `member1-cleaning`, propose the change, and create a pull request into your group's working branch.
6. Ask your group to review it and follow its merge process.

If the repository already has a `member1` folder, keep its existing work and add these files inside that folder. Include `.gitignore`; if the web upload omits it, create `member1/.gitignore` using the provided contents.

GitHub browser uploads allow at most 25 MiB per file; ordinary GitHub repository files must not exceed 100 MiB. Every file in this small package is below the browser limit.

Upload instructions: https://docs.github.com/en/repositories/working-with-files/managing-files/adding-a-file-to-a-repository
File-size guidance: https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github

Keep future commits meaningful: commit actual edits, query work, or documentation improvements as you make them. Do not split unchanged work into artificial commits to inflate contribution counts.
