# tm_literature
The respository outlines a semi-automated, text mining-based appraoch to search and selection of literature for review analysis. The repository is a companion for the following paper:

Puhr, H., (2021). *Value-Drivers and Constraints of Operational Flexibility: A Text-Mining-Based Literature Review*. (SSRN Working Paper 4173112). Available at [ https://ssrn.com/abstract=4173112]( https://ssrn.com/abstract=4173112).


## Repository structure
```
tm_literature
\_ Code
\_ Data
\_ Plots
```

## Code files
```
tm_literature
\_ Code
	\_ 00_setup_packages.r
	\_ 01_prepare_data.r
	\_ 02_extract_term_frequency.r
	\_ 03_run_literature_search.r
	\_ 04_analyze_results.r
```

## Data files
```
tm_literature
\_ Data
	\_ input
	\_ output
	\_ r_files
```
		
### Input
```
tm_literature
\_ Data
	\_ input
		\_ wos_base
		|	\_ Base Reference #1
		|	|	\_ savedrecs.txt (Export from Clarivate Analytics Web of Science in "Bibtex or Plain Text" format)
		|	\_ Base Reference #2
		|	|	\_ savedrecs.txt
		|	\_ ...
		\_ wos_jour
		|	\_ Journal #1
		|	|	\_ savedrecs1.txt
		|	|	\_ savedrecs2.txt
		|	|	\_ ...
		|	\_ Journal #2
		|	|	\_ savedrecs1.txt
		|	|	\_ savedrecs2.txt
		|	|	\_ ...
		|	\_ ...
		\_ in_evaluation.xlsx
```

### Output
```
tm_literature
\_ Data
	\_ output
		\_ base_term_frequencies.xlsx
		\_ data_results.xlsx
		\_ hit_pattern.html
		\_ papers_todo.xlsx
		\_ pub_jour_base.html
		\_ pub_jour_ref.html
		\_ pub_jour_result.html
		\_ pub_period_result.html
```

### R files
```
tm_literature
\_ Data
	\_ r_files
		\_ data_results.rds
		\_ data_results_full.rds
		\_ data_wos_base.rds
		\_ data_wos_jour.rds
```

## Plots
```
tm_literature
\_ Plots
	\_ pattern_001.png
	\_ pattern_002.png
	\_ ...
	\_ wordclould_bigram.png
	\_ wordlcould_word.png
```
