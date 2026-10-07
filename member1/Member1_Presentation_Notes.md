# Member 1 — simple cleaning presentation

## Slide 1: What is the data?
- 3,421,083 orders from 206,209 customers.
- 49,688 catalog products and 33,819,106 supplied purchase lines.
- We processed all six source files, not a sample.

## Slide 2: One real correction — spaces in product names
- We standardized spacing in 424 names and kept every product ID.
- Show figures/01_spacing_before_after.png: spacing issues fall from 424 to 0.

| Real example | Before | After | Why useful later |
| --- | --- | --- | --- |
| Product 18 | `Pizza for One Suprema  Frozen Pizza` | `Pizza for One Suprema Frozen Pizza` | Consistent text lookup and display |
| Product 7484 | `Southern Butter Pecan[NBSP]Gelato` | `Southern Butter Pecan Gelato` | Replace an unusual space with a normal space |
| Product 44990 | `Complete Mint Flavor Satin Floss[NBSP]` | `Complete Mint Flavor Satin Floss` | Remove an invisible space at the end |

`[NBSP]` marks an unusual no-break space. These are real source records.

## Slide 3: Missing values, duplicates, and valid values
- All 206,209 blank previous-order gaps belong to first orders. Keep them missing and import as SQL NULL.
- A first order has no earlier order; zero would mean a recorded zero-day gap.
- 67,755 actual zero-day gaps are retained.
- Full-row and key checks found zero accidental duplicates across the supplied files and combined purchases.
- 37 groups have the same cleaned name but different IDs. Keep them separate; product names are not unique keys.
- Valid hours, categories, and purchase references support correct GROUP BY calculations and joins.

Show figures/02_missing_before_after.png. The missing-value count stays the same because those blanks are meaningful.

## Slide 4: Easy dataset patterns and team handoff
Choose one or two of these charts:
- **When are most orders placed?** The peak is 10:00 with 288,418 orders. Use figures/03_orders_by_hour_before_after.png.
- **Which departments have the most catalog products?** personal care has 6,563. Use figures/04_department_products_before_after.png. This measures catalog variety, not popularity or sales.
- **How many different products are in a typical basket?** The median is 8; the most common range is 1–5. Use figures/05_basket_size_before_after.png.
- These distributions match before and after because valid records and buying patterns are preserved.
- Send the cleaned ZIP to the team: five CSVs, examples, charts, and checks. No records were removed.

## How each cleaning decision helps the next steps

| Cleaning decision | How it helps |
| --- | --- |
| Fix spaces in labels | Consistent text search, readable query output, and readable charts |
| Keep first-order blanks as NULL | Correct averages of known gaps; no invented zero-day orders |
| Check full rows and ID/purchase keys | Avoid inflated order, product, and basket counts |
| Keep different IDs with matching names | Preserve valid products and purchases; join on IDs |
| Validate hours, flags, and gaps | Trustworthy hourly groups, reorder rates, and repeat-order timing |
| Validate references | MySQL joins connect purchases to real orders and products |
| Retain valid zeros and large baskets | Preserve actual customer behavior |

## Suggested 90-second explanation
We prepared the complete Instacart dataset for our team's database work. First, we checked spaces, missing values, duplicates, and invalid values. We found a real formatting issue in 424 product names. For example, two spaces inside a product name became one normal space. This makes names consistent while keeping all IDs. Next, all 206,209 missing previous-order gaps belonged to first orders. We kept them missing because a first order has no previous order. Filling them with zero would distort later averages. We also checked complete duplicate rows and repeated keys across all files. There were no accidental duplicates. Some names matched after cleaning, but their product IDs differed, so we kept those entries. Finally, we verified allowed values and relationships, created simple charts, and exported the files. The before-and-after distributions are the same because all valid orders and purchases are preserved.

## Questions you can answer simply
- **Why did the missing count not decrease?** First-order gaps are correctly missing. Removing or filling them would change their meaning.
- **Why did matching names increase?** Spacing differences were removed. Different IDs still identify separate records.
- **Why not replace every unusual value?** A large basket or zero-day gap can be valid. We checked its context before deciding.
- **Why do the data charts match?** Cleaning labels and preserving correct NULLs should not remove valid activity.
- **Are these sales or quantities?** No. The data contains product lines, not prices or purchased quantities.
- **How many rows were deleted?** Zero; there was no evidence that deletion was needed.
