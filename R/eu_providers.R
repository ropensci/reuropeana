#' Search Europeana data providers.
#'
#' @export
#' @param providerid Provider ID
#' @param datasetid Dataset ID
#' @param datasets (logical) Whether to return datasets or not with provider information. Ignored
#' when providerid is NULL (the default for that parameter).
#' @param limit	(numeric) Size of the result set to fetch. Default: 10
#' @param start (numeric) Record number to start with. Default: 1
#' @param country_code (character) Two-letter ISO 3166-1 country code. Not all countries give data
#' back of course, for example, there is no data for country_code='US'.
#' @param key Your Europeana API key.
#' @param ... Curl options passed on to \code{\link[httr]{GET}}
#' @examples \dontrun{
#' eu_providers(limit = 1)
#' eu_providers(limit = 1, start = 3)
#' out <- eu_providers(limit = 3)
#' out$meta
#' out$items
#' eu_providers(start = 3)
#' eu_providers(providerid = '004')
#' eu_providers(providerid = '004', datasets = TRUE)
#' eu_providers(providerid='045')
#' eu_providers(datasetid = 2023901)
#' identical(eu_providers(providerid = 20239, datasets = TRUE)$items,
#'    eu_providers(datasetid = 2023901)$items)
#'
#' # Country codes
#' out <- eu_providers(country_code = 'UK')
#' ### check that all country fields are UK
#' vapply(out$items, "[[", "", "country")
#'
#' # Curl debugging
#' library("httr")
#' eu_providers(limit = 1, config = verbose())
#' }

eu_providers <- function(providerid = NULL, datasetid = NULL, datasets = FALSE,
  limit = 10, start = 1, country_code = NULL, key = getOption("eu_key"), ...) {

  stopifnot(if (!is.null(providerid)) is.null(datasetid) else TRUE)
  stopifnot(if (!is.null(datasetid)) is.null(providerid) else TRUE)

  url <- paste0(eubase(), '/providers.json')
  if (!is.null(providerid)) {
    if (datasets) {
      url <- sprintf('%s/provider/%s/datasets.json', eubase(), providerid)
    } else {
      url <- sprintf('%s/provider/%s.json', eubase(), providerid)
    }
  }
  if (!is.null(datasetid)) url <- sprintf('%s/dataset/%s.json', eubase(), datasetid)

  args <- euc(list(wskey = key, countryCode = country_code, offset = start, pagesize = limit))
  out <- eu_GET(url, args, ...)
  list(meta = out[ !names(out) %in% "items" ], items = out$items)
}
