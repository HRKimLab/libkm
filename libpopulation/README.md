# libpopulation

In the exploratory data analysis phase, you want to visualize data in many different ways and also want to know whether the patterns you observe are statistically significant. libpopulation provides an integrative way of visualizing data, check missing values, and perform relevant statistical tests. You write less, debug less, but get rich results. 
What that practically means is, in a meeting, you have less chances to say "I am sorry but actually that was not significant...". In other words, these functions can  make the scientific decision-making process efficient.

see demo_population_analysis.m for a demo with detailed comments.

# What you can do

- plot a scatter with relevant stats
- plot a histogram with relevant stats
- plot a bar graph with relevant stats
- plot multiple line plots and averages
- plot population tuning curces

# Statistical tests

By default, it performs nonparametric tests (e.g., Wilcoxon rank-sum test; Wilcoxon signed-rank test; Significance test for Spearman correlation). Some functions support options to use parametric tests ('test_type' option). Please be aware that all statistical tests are 'first-step' results. If you want to use it in the journal article, you need to make sure that the right statistical tests are performed by checking the code or perform tests on your own.

# Examples

![Fig1](https://github.com/hkim09/libkm/blob/master/libpopulation/demo_Fig1.png)
![Fig2](https://github.com/hkim09/libkm/blob/master/libpopulation/demo_Fig2.png)
![Fig3](https://github.com/hkim09/libkm/blob/master/libpopulation/demo_Fig3.png)
