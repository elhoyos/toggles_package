Survival of toggles by categories
================

### Survival of toggles for each project

``` r
data %>%
  ggplot( aes(x=repo_name, y=weeks_survived, fill=repo_name) ) +
    geom_violin(scale = "width", draw_quantiles = c(0.5)) +
    theme(
      legend.position = "none"
    ) +
    coord_flip() +
    facet_grid(rows = vars(all_routers_removed)) +
    scale_y_log10() +
    xlab("") +
    ylab("Weeks survived")
```

![](categories_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

### Survival of removed toggles for each project, detailed by category

Useful to determine if a toggle is living longer than the ones that have
been already removed.

``` r
data %>%
  filter(all_routers_removed == TRUE) %>%
  ggplot( aes(x=repo_name, y=weeks_survived, fill=repo_name) ) +
    geom_violin(scale = "width", draw_quantiles = c(0.5)) +
    coord_flip() +
    scale_y_log10() +
    facet_grid(cols = vars(category)) +
    theme(legend.position = "none") +
    xlab("") +
    ylab("Weeks survived")
```

![](categories_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

# Survival of toggles per category

``` r
data %>%
  ggplot( aes(x=category, y=weeks_survived, fill=category) ) +
    geom_violin(scale = "width", draw_quantiles = c(0.5)) +
    geom_jitter(height = 0, width = 0.1) +
    coord_flip() +
    scale_y_log10() +
    facet_grid(rows = vars(all_routers_removed)) +
    theme(legend.position = "none") +
    xlab("") +
    ylab("Weeks survived")
```

![](categories_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->