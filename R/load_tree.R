#' Load phylogenetic tree
#'
#' @param tree_file File path to phylogenetic tree
#'
#' @returns A multiPhylo tree object
#'
load_tree <- function(tree_file) {

  # load tree object
  tree <- ape::read.nexus(tree_file)

  # manually fix branch lengths with very small lengths (for modelling)
  for (t in 1:length(tree)) {
    for (i in which(tree[[t]]$edge.length < 0.001)) {
      tree[[t]]$edge.length[i] <- 0.001
    }
  }

  # return
  tree

}
