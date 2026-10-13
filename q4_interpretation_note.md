# Q4 interpretation note

Status: awaiting Oracle validation.

The implemented interpretation is: first calculate each non-European
country's total `amount_sold` for 1999, retain only countries above $500,000,
then aggregate `quantity_sold` by channel across those eligible countries and
return the top three channels.

This matches the grammatical scope of “countries ... that had a total sales
amount greater than $500,000” and avoids treating $500,000 as a per-channel
threshold. The Canvas rubric contains no alternative Q4 rule. The validation
script prints the eligible countries before the channel result so the applied
population is auditable.
