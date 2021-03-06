#' @title plot the size factors using different strategies.
#'
#' @param sep a \code{\link{SummarizedExomePeak}} object.
#'
#' @examples
#'
#' ### Load the example SummarizedExomPeak object
#' f1 = system.file("extdata", "sep_ex_mod.rds", package="exomePeak2")
#'
#' sep <- readRDS(f1)
#'
#' ### Visualize the size factors estimated using different regions
#' plotSizeFactors(sep)
#'
#' @return A ggplot.
#'
#'@import ggplot2
#'@import reshape2
#'
#'@importFrom reshape2 melt
#'
#'@aliases plotSizeFactors
#'
#'@rdname plotSizeFactors-methods
#'
#'@export
#'
#'
setMethod("plotSizeFactors",
          "SummarizedExomePeak",
                function(sep){
 plot_df <- vapply(c("Background","All","Modification"),
                   function(x) estimateSeqDepth(sep,from = x)$sizeFactor,
                   numeric(ncol(sep)))
 plot_df <- melt(plot_df)
 colnames(plot_df) <- c("bam_files","Estimation_Methods","size_factors")
 plot_df$Estimation_Methods <- factor(plot_df$Estimation_Methods, levels = c("Background","All","Modification"))
 plot_df$bam_files <- as.factor( plot_df$bam_files )
 plot_df$IP_input <- "input"
 plot_df$IP_input[rep(sep$design_IP ,3)] <- "IP"
 plot_df$Treatment <- "untreated"
 plot_df$Treatment[rep(sep$design_Treatment ,3)] <- "treated"
 plot_df$samples <- paste0(plot_df$Treatment,"_",plot_df$IP_input)

 Rep_marks <- paste0("Rep", rep(sequence((table(plot_df$samples)/3)[unique(plot_df$samples)]),3))

 plot_df$samples <- paste0(plot_df$samples,"_", Rep_marks)
 ggplot(plot_df,aes(x = samples, y = size_factors)) +
   geom_bar(stat = "identity",
            position = "dodge",
            aes(fill = Estimation_Methods),
            width = 0.8,
            colour = "black") +
   theme_classic() +
  scale_fill_brewer(palette = "Dark2") +
   theme(axis.text.x = element_text(angle = 310,hjust = 0,face = "bold",colour = "darkblue")) +
   labs(x = "Samples", y = "Sequencing Depth Size Factors", title = "Size Factors Estimated on Different Features") +
   theme( plot.margin = margin(t = 1,
                               r = 0.5,
                               b = 0.5,
                               l = 1.5,
                               unit = "cm") )

})
