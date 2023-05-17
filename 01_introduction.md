# Introduction



## What are network data?

Networks are relational data, whereby entities across all types of domains (actors, companies, species, topics, etc.) are connected based on one or more types of relationships (friendship, trade, pollination, in-text co-occurrence, etc.)

Networks are useful for studying interdependencies because their structure suggest that entities and their connections inter-relate. Network analytical approaches typically evaluate questions these interdependencies from two perspectives. One is that of _selection_, whereby an actors choose to make connections based on certain characteristics/decision criteria. For example, a bee may choose to pollinate a certain flower based on its size or scent. A second perspective is that of _influence_, whereby connections are affecting the characteristics/decisions of actors. For example, being friends with someone who smokes may cause the non-smoker to take up smoking. 

### Features of a network  

Networks are composed of 'nodes', the data points that represent an entity (also called vertex), and 'edges', representing the relationship between the nodes. These network structures are represented in Figure 1.



<div class="figure">
<img src="01_introduction_files/figure-html/unnamed-chunk-2-1.png" alt="Components of a network" width="672" />
<p class="caption">(\#fig:unnamed-chunk-2)Components of a network</p>
</div>

**Network 'mode'**: Networks can take several forms with variation in what kinds of connections can occur. One important distinction can be made between **one-mode and two-mode networks**. One-mode networks assumes that the nodes are all capable of making connections while two-mode networks assume that nodes of one type can only have relationships to nodes of a different type. Using the example of board members and corporations, Jasny (2012)^[Jasny, Lorien. “Baseline Models for Two-Mode Social Network Data.” Policy Studies Journal 40, no. 3 (2012): 458–91. https://doi.org/10.1111/j.1541-0072.2012.00461.x.] explains: 'Ties between the board members themselves (e.g., friendship ties) would constitute a one-mode network. Ties between companies (e.g., if the first company supplied the second with raw materials) would also be a one-mode network. The two-mode network is formed by ties from the board members, the first mode, to the boards of companies they sit on, the second mode.' These two-mode networks, also called bipartite networks, assume that connections cannot be made within each mode (e.g. directly between companies' boards).

<div class="figure">
<img src="01_introduction_files/figure-html/unnamed-chunk-3-1.png" alt="Two types of networks" width="49%" /><img src="01_introduction_files/figure-html/unnamed-chunk-3-2.png" alt="Two types of networks" width="49%" />
<p class="caption">(\#fig:unnamed-chunk-3)Two types of networks</p>
</div>

**Node attributes**: In both one and two mode networks, nodes have attributes. **Node attributes** are associated data that describe the entity, which can be either endogenous to the network (i.e. a characteristic of the node based on their place in the network) or exogenous (i.e. a characteristic of the node unrelated to their place in the network). Examples of endogenous node attributes are features of the node in relation to the network, such as their degree centrality. Examples of exogenous node attributes could be the gender of an individual, the sector a company works in, the weight or species of a pollinator, or the author of a word's corpus. 

**Directionality**: The ties that connect entities in a network can be **directed or undirected**. Directed networks assume that there is a 'sender' and 'receiver' of an edge, and that the difference between these two matter (e.g. transmitting a disease). On the other hand, undirected networks assume that the connection is based on a mutual relationship (e.g. co-authorship). Whether or not edges are directed will alter our understanding of the network structure, since each connection-based statistic will be divided into incoming and outgoing connections. 

<div class="figure">
<img src="01_introduction_files/figure-html/unnamed-chunk-4-1.png" alt="Network directionality" width="49%" /><img src="01_introduction_files/figure-html/unnamed-chunk-4-2.png" alt="Network directionality" width="49%" />
<p class="caption">(\#fig:unnamed-chunk-4)Network directionality</p>
</div>

**Edge attributes**: Just like with nodes, edges can also have attributes. **Edge attributes** can be endogenous to the network, such as the 'weight' of the tie (multiple connections) and/or exogenous, such as the _type_ of connection. For example, individuals in a network can be connected through different relationships (e.g. classmates, friends), companies can trade information and/or material goods; pollinators can visit or pollinate. Depending on how a researcher wants to analyze a network, these various types of connections can be considered to exist across multiple 'levels'.

### Network statistics 

Summaries of networks are usually described at two levels: the network-level and the actor-level. We define a few below to standardize some of the terminology used in this workshop.

**Network-level statistics**

* Size: Number of nodes and/or number of connections
* Density: Number of edges out of all possible edges
* Centralization: Propensity for nodes to connect to few or many nodes; closely related to degree distribution
* Transitivity/clustering coefficient (global): The ratio of the count of triangles and connected triples in the graph (e.g. propensity for 'triadic closure' across a whole network) 

**Actor-level**  

* Several types of centrality, which is a measure of an actors' connectedness based on...
  * Degree: The number of connections an actors has
  * Betweeness: The number of shortest paths
  * Eigenvector: The influence based on connections and the propensity of their connections to have connections
* Transitivity/clustering coefficient (local): The ratio of the count of triangles connected to the vertex and the triples centered on the vertex (e.g. how dense the 'neighborhood' of an actor is)
  
## Storing network data

Network data, which record the relationships (edges) between nodes, are typically stored in one of two ways: edge lists or matrices. **Edge lists** are columns of data, whereby the positioning of two nodes next to one another in a column indicates a connection. In a one-mode undirected network, the position of names in the columns have little meaning (A -> B = B <- A). In a one-mode directed network, however, the columns take on a meaning, where the first column is a list of names from which a connection originated (e.g. 'from', also called 'ego'), and the second column is a list of names to whom the connection is made (e.g. 'to', also called 'alter'). In these cases, A -> B != B -> A. In two-made networks, where nodes of mode 1 can only connect to nodes of mode 2, but not one another, each column will represent a mode and nodes listed in one column cannot be in the other.

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:unnamed-chunk-5)One-mode edge list</caption>
 <thead>
  <tr>
   <th style="text-align:center;"> ego </th>
   <th style="text-align:center;"> alter </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> A </td>
   <td style="text-align:center;"> B </td>
  </tr>
  <tr>
   <td style="text-align:center;"> B </td>
   <td style="text-align:center;"> B </td>
  </tr>
  <tr>
   <td style="text-align:center;"> C </td>
   <td style="text-align:center;"> H </td>
  </tr>
  <tr>
   <td style="text-align:center;"> D </td>
   <td style="text-align:center;"> E </td>
  </tr>
  <tr>
   <td style="text-align:center;"> E </td>
   <td style="text-align:center;"> G </td>
  </tr>
  <tr>
   <td style="text-align:center;"> F </td>
   <td style="text-align:center;"> C </td>
  </tr>
  <tr>
   <td style="text-align:center;"> G </td>
   <td style="text-align:center;"> H </td>
  </tr>
  <tr>
   <td style="text-align:center;"> H </td>
   <td style="text-align:center;"> J </td>
  </tr>
  <tr>
   <td style="text-align:center;"> I </td>
   <td style="text-align:center;"> A </td>
  </tr>
  <tr>
   <td style="text-align:center;"> J </td>
   <td style="text-align:center;"> F </td>
  </tr>
</tbody>
</table>

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:unnamed-chunk-5)Two-mode edge list</caption>
 <thead>
  <tr>
   <th style="text-align:center;"> mode1 </th>
   <th style="text-align:center;"> mode2 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> A </td>
   <td style="text-align:center;"> O </td>
  </tr>
  <tr>
   <td style="text-align:center;"> B </td>
   <td style="text-align:center;"> K </td>
  </tr>
  <tr>
   <td style="text-align:center;"> C </td>
   <td style="text-align:center;"> K </td>
  </tr>
  <tr>
   <td style="text-align:center;"> D </td>
   <td style="text-align:center;"> M </td>
  </tr>
  <tr>
   <td style="text-align:center;"> E </td>
   <td style="text-align:center;"> L </td>
  </tr>
  <tr>
   <td style="text-align:center;"> F </td>
   <td style="text-align:center;"> L </td>
  </tr>
  <tr>
   <td style="text-align:center;"> G </td>
   <td style="text-align:center;"> O </td>
  </tr>
  <tr>
   <td style="text-align:center;"> H </td>
   <td style="text-align:center;"> N </td>
  </tr>
  <tr>
   <td style="text-align:center;"> I </td>
   <td style="text-align:center;"> N </td>
  </tr>
  <tr>
   <td style="text-align:center;"> J </td>
   <td style="text-align:center;"> K </td>
  </tr>
</tbody>
</table>


**Matrices** are the graph form for storing relational data. Nodes are listed as the rows and columns, and if two nodes are connected, a value is put into the matrix where they intersect. If two nodes do not have a connection, the value at their intersection is zero. The differences we pointed out in edge lists (directed/undirected, one-mode/two-mode) are reflected in the shape and symmetry of the matrix. One-mode undirected networks are square (i.e. the same nodes are represented in both the rows and columns) and symmetrical (i.e. the values across the diagonal are the same). In one-mode directed networks, the matrix is still square but the matrix is asymmetric: because it may be that nodeA -> nodeB, inputting a value of 1 in row 1 and column 2, but if nodeB !-> nodeA, there is a value of 0 in row 2 and column 1. In a two-mode network the matrix is likely rectangular, where mode one nodes are represented in the rows and mode two nodes are represented in the columns. Typically, two mode networks are not directed. 

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:unnamed-chunk-6)Undirected one-mode adjacency matrix</caption>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:center;"> A </th>
   <th style="text-align:center;"> B </th>
   <th style="text-align:center;"> C </th>
   <th style="text-align:center;"> D </th>
   <th style="text-align:center;"> E </th>
   <th style="text-align:center;"> F </th>
   <th style="text-align:center;"> G </th>
   <th style="text-align:center;"> H </th>
   <th style="text-align:center;"> I </th>
   <th style="text-align:center;"> J </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> A </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> B </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> D </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> E </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> F </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> G </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> H </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> I </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> J </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
</tbody>
</table>

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:unnamed-chunk-6)Undirected two-mode adjacency matrix</caption>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:center;"> O </th>
   <th style="text-align:center;"> K </th>
   <th style="text-align:center;"> M </th>
   <th style="text-align:center;"> L </th>
   <th style="text-align:center;"> N </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> A </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> B </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> C </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> D </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> E </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> F </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> G </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> H </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> I </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> J </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
   <td style="text-align:center;"> 0 </td>
  </tr>
</tbody>
</table>
