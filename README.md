# tm_literature
The respository outlines a semi-automated, text mining-based appraoch to search and selection of literature for review analysis. The repository is a companion for the following paper:

Puhr, H., (2021). *Value-Drivers and Constraints of Operational Flexibility: A Text-Mining-Based Literature Review*. (SSRN Working Paper 4173112). Available at [ https://ssrn.com/abstract=4173112]( https://ssrn.com/abstract=4173112).


## Repository structure

The repository containts the following three folders:

```
tm_literature
\_ Code
\_ Data
\_ Plots
```

Each of the folders and its contents are described in detail below.

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

* The file `00_setup_packages.r` ensures that all necessary packages are installed.
* In `01_prepare_data.r` all files in *Data/input* are imported and prepared for further analysis.
* The file `02_extract_term_frequency.r` the relevant search terms are identfied based on term frequency-inverse document frequency.
* In `03_run_literature_search.r` the results for queries based on the results from `02_extract_term_frequency.r` are analyzed to iterartively define search terms. For optimal definition of search terms, users can define and test their search terms with [regular expressions](https://stringr.tidyverse.org/articles/regular-expressions.html).
* In `04_analyze_results.r` the results from the literature selection are summarized in tables and plots.

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
		|	|	\_ savedrecs.txt
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

The code requires data to be organized into two folders: `wos_base` and `wos_jour`.

* The folder "wos_base" contains exports from Web of Science that constitute the "base literature". This may be those studies that cite seminal studies in the field.
* The folder "wos_jour" contains exports from Web of Science that constitute the corpus of literature in which the review is conducted. This may be a full export from all relevant journals.

Both folders should include exports from Clarivate Analytics Web of Science
in "Bibtex or Plain Text" format saved as txt-files. The code is organized in
a way to handle sub-directories to better organize the exports.

The file `in_evaluation.xlsx` is an Excel file where users can handle their
manual screening and selection of the literature. The file contains the
following columns:

* paper: Author and year citation of the paper
* id: Web of Science ID of the paper
* included_screen: TRUE/FALSE flag whether the paper is included after screening screening
* included_read: TRUE/FALSE flag whether the paper is included after screening screening
* comment: Column to enter comments on the paper

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

* The file `base_term_frequencies.xlsx` shows the frequency of words and bigrams in the base literature corpus. The file is an output from `02_extract_term_frequency.r`.
* The file `data_results.xlsx` contains all references included in the base literature corpus. The is an output from `03_run_literature_search.r`.
* The file `data_todo.xlsx` contains all references included in the base literature corpus that still require screening for inclusion. The is an output from `03_run_literature_search.r`.
* The files `hit_pattern.html`, `pub_jour_base.html`, `pub_jour_ref.html`, `pub_jour_result.html`, and `pub_period_result.html` are summary tables that are generated by `04_analyze_results.r`.

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
	\_ wordcloud_bigram.png
	\_ wordcloud_word.png
```

* The files `pattern_xxx.png` summarize the results by search term. This allows users to identify false-positive results and shows where they need to further adapt their search terms with regular expressions. The plots are an output from `03_run_literature_search.r`.
* The files `wordcloud_bigram.png` and `wordcould_word.png` are wordclouds that show the most frequent terms in the dataset. The plots are an output from `02_extract_term_frequency.r`.
