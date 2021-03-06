#' download
#' 
#' Convenience function to retrieve LINCS L1000 data and metadata files.
#' 
#' @param x  A Slinky object
#' @param type  Type of file to retrieve: expression, info
#'    (instance level), or readme file. 
#' @param level  Level of data desired (if type is expression): 2,
#'    3 (default), 4, or 5.
#' @param phase  What phase of data is desired, 1 of 2?  Currently
#'    only 1 is supported. Phase 2 files may be used with this package,
#'    but must be downloaded manually.  Phase 2 support planned for next 
#'    update.
#' @param prompt  Warn before downloading huge files?  Default is
#'    FALSE.
#' @param verbose  Do you want to know how things are going?
#'    Default is FALSE.
#' @return None
#' @note Most of these files are very large and may
#'    take many minutes to several hours to download. A fast and reliable
#'    connection is highly recommended.
#' @name download
#' @rdname download
setGeneric("download",
           function(x, type = c("expression", "info", "readme"),
                    level = 3,
                    phase = 1,
                    prompt = FALSE,
                    verbose = FALSE) {
             standardGeneric("download")
           }
)
#' @examples
#' # for build/demo only.  You MUST use your own key when using the slinky
#' # package.
#' sl <- new("Slinky")
#' \dontrun{
#' download(sl, type = "info")
#' }
#' 
#' @rdname download
#' @exportMethod download
#' @aliases download
#' @importFrom curl curl
setMethod("download", signature(x = "Slinky"),
          function(x, 
                   type = c("expression", "info", "readme"),
                   level = 3,
                   phase = 1,
                   prompt = FALSE,
                   verbose = FALSE) 
          {
            
            
            type = match.arg(type)
            outfn <- tempfile(tmpdir = "./")
            out <- file(outfn, "wb")
            
            if (phase != 1) {
              stop("Only Phase I data is supported at this time.")
            }
            if (type == "info") {
              con <- curl::curl(paste0("ftp://ftp.ncbi.nlm.nih.gov/geo/series/",
                                       "GSE92nnn/GSE92742/suppl/GSE92742_Broad_LINCS_inst_info.txt.gz"))
              of <- gsub(".*/", "", summary(con)$description)
              size = 11
            } else if (type == "readme") {
              con <- curl::curl(paste0("https://docs.google.com/document/d/1q2g",
                                       "ciWRhVCAAnlvF2iRLuJ7whrGP6QjpsCMq1yWz7dU/export?format=pdf"))
              of <- "GEO_cmap_lincs_userguide.pdf"
              size = 1
            } else if (level == 2) {
              con <- curl::curl(paste0("ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE92",
                                       "nnn/GSE92742/suppl/GSE92742_Broad_LINCS_Level2_GEX_epsilon_n1269",
                                       "922x978.gctx.gz"))
              of <- gsub(".*/", "", summary(con)$description)
              size = 2000
            } else if (level == 3) {
              con <- curl::curl(paste0("ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE92",
                                       "nnn/GSE92742/suppl/GSE92742_Broad_LINCS_Level3_INF_mlr12k_n13191",
                                       "38x12328.gctx.gz"))
              of <- gsub(".*/", "", summary(con)$description)
              size = 48800
            } else if (level == 4) {
              con <- curl::curl(paste0("ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE92",
                                       "nnn/GSE92742/suppl/GSE92742_Broad_LINCS_Level4_ZSPCINF_mlr12k_n1",
                                       "319138x12328.gctx.gz"))
              of <- gsub(".*/", "", summary(con)$description)
              size = 49600
            } else if (level == 5) {
              con <- curl::curl(paste0("ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE92",
                                       "nnn/GSE92742/suppl/GSE92742_Broad_LINCS_Level5_COMPZ.MODZ_n47364",
                                       "7x12328.gctx.gz"))
              of <- gsub(".*/", "", summary(con)$description)
              size = 19900
            } else {
              stop("Only level 2, 3, 4, and 5 are supported at this time.")
            }
            
            if (type == "expression" && level > 2) {
              if (prompt) {
                message("Download of large file (20-50GB) requested which, when ",
                        "expanded, will take up to 100GB of disk space. \nPlease",
                        "confirm you have enough disk space and press enter, ",
                        " or 'C' to cancel\n")
                continue <- readline(prompt = "Press [enter] to continue: ")
                if (continue == "C") {
                  stop("Dowload cancelled at user's request")
                }
              }
            }
            
            if (type == "readme") {
              if (verbose)
                message("Preparing pdf...this may take a minute\n\n")
              flush.console()
            }
            
            open(con, "rb", blocking = TRUE)
            read <- 1
            
            if (verbose) {
              message("Downloading file.  Progress:\n")
              flush.console()
              pb <- txtProgressBar(min = 0,
                                   max = size,
                                   initial = 0,
                                   width = 100,
                                   style = 3)
            }
            
            while (isIncomplete(con)) {
              buf <- readBin(con, raw(), 1024 * 1000)
              writeBin(buf, out)
              read <- read + 1
              if (verbose) utils::setTxtProgressBar(pb, read)
            }
            
            base::close(out)
            base::close(con)
            file.rename(outfn, of)
            
            if (type == "readme") {
              Biobase::openPDF(normalizePath(of))
            } else if (type != "info") { 
              if (verbose)
                message("\n\nGunzipping...")
              tryCatch({
                system2("gunzip", args = c("-f", of), stderr = TRUE,
                        stdout = TRUE)
                of <- gsub(".gz", "", of)
              }, error = function(e) {
                message("Failed to gunzip (perhaps gzip not installed on your system?.")
              })
            }
            if (verbose)
              message(paste0("\n\nDownload complete.  File saved to ",
                             getwd(), "/", of, "\n"))
            return(of)
          })

