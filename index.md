---
title: Network Visualization
author: Liza Wood
date: "2023-05-17"

github-repo: ucdavisdatalab/workshop_network_viz
url: "https://ucdavisdatalab.github.io/workshop_network_viz/"

lang: en-us

site: "bookdown::bookdown_site"
knit: "bookdown::render_book"
output:
  bookdown::gitbook:
    fig_caption: false
    config:
      toc:
        before: |
          <li><a href="https://datalab.ucdavis.edu/">
            <img src="https://datalab.ucdavis.edu/wp-content/uploads/2019/07/datalab-logo-full-color-rgb-1.png" style="height: 100%; width: 100%; object-fit: contain" />
          </a></li>
          <li><a href="./" style="font-size: 18px">Network visualization</a></li>
        after: |
          <a href="https://creativecommons.org/licenses/by-nc-sa/4.0/" target="_blank">
            <img alt="CC BY-SA 4.0" src="https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg" style="float: right; padding-right: 10px;" />
          </a>
        collapse: section
      sharing: no
      view: https://github.com/ucdavisdatalab/workshop_network_viz/blob/master/%s
      edit: https://github.com/ucdavisdatalab/workshop_network_viz/edit/master/%s
---

# Overview {-}

## Description  

Network science approaches are being increasingly used to explore complex interactions and the general connectivity among entities, from friends in a social network to the spread of a disease in a population. Due its complexity, network data is often explored and communicated using data visualizations. In this intermediate R workshop we will cover how to tell useful stories with network data primarily using the `statnet` suite of packages and the `ggraph` plotting package that is compatible with much of the `ggplot2` framework. In this interactive and hands-on workshop we'll practice using these packages in R to plot one-mode and two-mode networks. As we introduce functions unique to these packages we will discuss what visualization features best suit different types of network data and research communication goals. Along the way we will cover basic data preparation steps and how to calculate (or assign) key network descriptives including centrality measures, edge attributes, and community clusters for your plots.

## Learning goals 

After completing this workshop, learners should be able to:  

- Distinguish between `igraph` and `network` objects in R
- Identify the necessary components for visualizing network objects in `ggraph`
- Calculate network and node-level descriptives and integrate them into visualizations
- Select among various visualization strategies for diverse communication goals
- Create well-designed network figures 
- Identify where to go to learn more  


## Prerequisites

The target audience for this workshop is intermediate to advanced R users. This workshop will provide only a cursory introduction to network data and therefore is best suited for learners who have some familiarity working with networks and working with `ggplot2`. While workshop data will rely on social scientific examples (e.g., social connections and co-occurrence networks), the lessons learned relating to network visualizations can be applied to a wide variety of research questions and learners from all domains are welcome.
