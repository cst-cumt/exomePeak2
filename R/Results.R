#' @title Report the (Differential) Modification Peaks/Sites and their associated LFC Statistics
#' @param sep a \code{\link{SummarizedExomePeak}} object.
#'
#' @param cut_off_pvalue a \code{numeric} value for the p value cutoff in the exported result; Default \code{= NULL}.
#'
#' @param cut_off_padj a \code{numeric} value for the adjusted p value cutoff in the exported result; Default \code{= 0.05}.
#'
#' @param cut_off_log2FC a \code{numeric} value for the log2 fold change (LFC) cutoff of the exported result,
#' only the sites with abs(LFC) larger than this value are kept; Default \code{= 0}.
#'
#' @param min_num_of_positive a \code{numeric} value for the minimum number of reported sites.
#' If the number of remaining sites is less than this number after the filter, additional sites will be reported by the increasing order of the p value to meet this number.
#'
#' @param expected_direction a \code{character} for the expected direction of the differential modification, could be one in \code{c("hyper", "hypo", "both")}.
#'
#' \describe{
#'  \item{\strong{\code{hyper}}}{
#'  only report the peaks/sites with interactive LFC > 0.
#'  }
#'
#'  \item{\strong{\code{hypo}}}{
#'  only report the peaks/sites with interactive LFC < 0.
#'  }
#'
#'  \item{\strong{\code{both}}}{
#'  report the peaks/sites in both directions.
#'  }
#' }
#'
#' This argument is useful when the treated group involves the perturbation of a known writer or eraser protein; Default "both".
#'
#' @param inhibit_filter a \code{logical} for whether to remove all the filters, this option is useful when quantification on single based site annotation; Default \code{= FALSE}.
#'
#' @param table_style a \code{character} for the style of the table being returned, could be one in \code{c("bed","granges")}.
#'
#' \describe{
#'  \item{\strong{\code{bed}}}{
#'  The genomic locations in the table are represented by BEDgraph style.
#'  }
#'
#'  \item{\strong{\code{granges}}}{
#'  The genomic locations in the table are represented by GRanges style.
#'  }
#' }
#'
#'
#' @return a \code{data.frame} containing the genomic locations of modification peaks/sites, gene ids, and their statistics.
#'
#' @examples
#'
#' ### Load the example SummarizedExomPeak object
#' f1 = system.file("extdata", "sep_ex_mod.rds", package="exomePeak2")
#'
#' sep <- readRDS(f1)
#'
#' ### Check the modification peaks/sites statistics.
#' head(Results(sep))
#'
#' @importFrom rtracklayer export
#' @import GenomicRanges
#'
#' @aliases Results
#'
#' @rdname Results-methods
#'
#' @export
#'

setMethod("Results",
          "SummarizedExomePeak",
          function(sep,
                   cut_off_pvalue = NULL,
                   cut_off_padj = 0.1,
                   cut_off_log2FC = 0,
                   min_num_of_positive = 100,
                   expected_direction = c("both", "hyper", "hypo"),
                   inhibit_filter = FALSE,
                   table_style = c("bed", "granges")
                   ) {

            expected_direction <- match.arg(expected_direction)
            table_style <- match.arg(table_style)

            if (table_style == "bed") {
              if (file.access(".") != 0)
                stop(
                  "The current working directory is not accessible by R,
                  please consider change the table_style into 'granges'."
                )
            }

            #Check if users have not run inference on the summarizedExomePeak.

            if (is.null(exomePeak2Results(sep))) {
              if (any(sep$design_Treatment)) {
                sep <- glmDM(sep)
              } else{
                sep <- glm_M(sep)
              }
            }

            #Check the validity of the arguments.

            stopifnot(cut_off_pvalue <= 1 & cut_off_pvalue >= 0)
            stopifnot(cut_off_log2FC >= 0)
            table_style <- match.arg(table_style)

            #Decision for modification

            if (inhibit_filter){
              index_keep <- rep(T, sum(grepl("peak_", rownames(sep))))
            } else {

            if (!any(sep$design_Treatment)) {
              decision_mod <- decision_deseq2(
                Inf_RES = exomePeak2Results(sep),
                log2FC_cut = cut_off_log2FC,
                P_cut = cut_off_pvalue,
                Padj_cut = cut_off_padj,
                Min_mod = min_num_of_positive
              )

              #If no sites are reported, export all the p values that are not NA.

              index_keep <-
                which(
                  (exomePeak2Results(sep)[[decision_mod$Cut_By_expected]] < decision_mod$Cut_Val_expected) &
                    (exomePeak2Results(sep)$log2FoldChange > cut_off_log2FC)
                )

            } else {
              decision_dm <- decision_deseq2(
                Inf_RES = exomePeak2Results(sep),
                log2FC_cut = cut_off_log2FC,
                P_cut = cut_off_pvalue,
                Padj_cut = cut_off_padj,
                Min_mod = min(min_num_of_positive,nrow(exomePeak2Results(sep))),
                Exp_dir = expected_direction
              )

              if (expected_direction == "both") {
                indx_es <-
                  (abs(exomePeak2Results(sep)$log2FoldChange) > cut_off_log2FC)
              } else {
                if (expected_direction == "hyper") {
                  indx_es <- (exomePeak2Results(sep)$log2FoldChange > cut_off_log2FC)
                } else {
                  indx_es <- (exomePeak2Results(sep)$log2FoldChange < -1 * cut_off_log2FC)
                }
              }

              index_keep <-
                which(exomePeak2Results(sep)[[decision_dm$Cut_By_expected]] < decision_dm$Cut_Val_expected &
                        indx_es)

              if (length(index_keep) == 0) {
                stop(
                  "No sites could be left using the current filter, please change into a less rigorous one."
                )
              }
            }
            }

            #Create the final result summary that contain GRangesList with metadata collumns.
            result_grl <-
              rowRanges(sep)[grepl("peak_", rownames(sep))][index_keep]
            result_stat <- exomePeak2Results(sep)[index_keep, ]


            result_gr <- unlist(result_grl)
            result_gr$gene_id <-
              gsub("\\.[0-9]*$", "", result_gr$gene_id)
            names(result_gr) <-
              gsub("\\..*$", "", names(result_gr))

            if (!any(sep$design_Treatment)) {
              colnames(result_stat)[colnames(result_stat) == "log2FoldChange"] = "mod.log2.fc"
              rownames(result_stat) = NULL

            } else {
              colnames(result_stat)[colnames(result_stat) == "log2FoldChange"] = "diff.log2.fc"
              rownames(result_stat) = NULL

            }

            result_grl <- split(result_gr, names(result_gr))
            mcols(result_grl) <- result_stat


            id_num <-
              as.numeric(gsub("^.*_", "", names(result_grl)))
            id_index <- order(id_num)
            renamed_id <-
              paste0("peak_", rep(seq_along(id_num), table(id_num[id_index])))
            result_grl <- result_grl[id_index, ]
            names(result_grl) <- renamed_id

            #sort grl

            if (table_style == "granges") {
              result_df <- as.data.frame(result_grl)
              result_df <-
                result_df[, colnames(result_df) != "group"]
              colnames(result_df)[colnames(result_df) == "group_name"] = "mod_name"
              result_df <-
                cbind(result_df, as.data.frame(mcols(result_grl))[rep(seq_along(result_grl), elementNROWS(result_grl)), ])

            } else {
              scores <- -1 * log2(mcols(result_grl)$padj)

              scores[is.na(scores)] <- 0

              mcols(result_grl)$score <- scores

              export(object = result_grl,
                     con = "temp___1.bed",
                     format = "BED")

              result_df <-
                read.table("temp___1.bed", header = F, sep = "\t")

              file.remove("temp___1.bed")

              colnames(result_df) <- c(
                "chr",
                "chromStart",
                "chromEnd",
                "name",
                "score",
                "strand",
                "thickStart",
                "thickEnd",
                "itemRgb",
                "blockCount",
                "blockSizes",
                "blockStarts"
              )

              result_df$geneID <- vapply( result_grl , function(x) x$gene_id[1] , character(1))

              mcols(result_grl) <-
                mcols(result_grl)[, !colnames(mcols(result_grl)) %in% "score"]

              result_df <-
                cbind(result_df , as.data.frame(mcols(result_grl)))

            }

            indx_reads_count <- grepl("Count",colnames(result_df))
            indx_major_stat <- colnames(result_df) %in% c("log2FoldChange","pvalue","padj")

            result_df <- result_df[,!grepl("MLE|MAP|.padj|.pvalue",colnames(result_df))]

            return(result_df)

            })
