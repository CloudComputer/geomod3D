#' @include spatial3DDataFrame.R

#### points3DDataFrame class ####
#' 3D point cloud with attributes
#'
#' A 3D point cloud. Extends the \code{spatial3DdataFrame} class.
#'
#' @slot coords A \code{list} containing the coordinates for each data unit.
#' @slot data A \code{data.frame} with each data unit's attributes.
#' @slot bbox A \code{matrix} containing the coordinates of two opposing
#' edges of the object's bounding box.
#'
#' @seealso \code{\link{spatial3DDataFrame-class}},
#' \code{\link{points3DDataFrame-init}}
#'
#' @export points3DDataFrame
points3DDataFrame <- setClass(
  "points3DDataFrame",
  contains = "spatial3DDataFrame",
  validity = function(object) {
    if (length(object@coords) != nrow(object@data))
      stop("Number of coordinates does not match number of observations")
    if (!all(rapply(object@coords, class) == "numeric"))
      stop(
        "Invalid object in points list. All objects must be of class 'numeric'"
      )
  }
)

#### constructor ####
#' 3D point cloud with attributes
#'
#' @param coords A list, matrix, or data frame containing the 3D coordinates
#' of the points.
#' @param df A data frame with the points' attributes
#'
#' @details If \code{coords} is a matrix or data frame with less than 3
#' columns, the missing coordinates are given a value of 0.
#'
#' @seealso \code{\link{spatial3DDataFrame-class}},
#' \code{\link{points3DDataFrame-class}}
#'
#' @name points3DDataFrame
points3DDataFrame <- function(coords, df){

    # coordinates
    if (missing(coords))
      coords <- list()
    else if (any(class(coords) %in% c("matrix", "Matrix", "data.frame", "tbl_df"))){
      coords <- as.matrix(coords)
      # enforcing 3D
      if (ncol(coords) > 3)
        stop("Invalid number of dimensions")
      coords <- cbind(coords, matrix(0, nrow(coords), 3 - ncol(coords)))
      # making list
      coords <- apply(coords, 1, function(x) list(x))
      coords <- lapply(coords, unlist)
    }else if (class(coords) == "list"){
      if (!(all(sapply(coords, length) == 3)))
        stop("Invalid number of dimensions")
    }else
      stop("Invalid format for coordinates")
    Ndata <- length(coords)

    # bounding box
    if (Ndata > 0){
      points_df <- data.frame(t(sapply(coords, function(z) z)))
      colnames(points_df) <- c("X", "Y", "Z")
      bbox <- as.matrix(rbind(
        apply(points_df, 2, min),
        apply(points_df, 2, max)))
      rownames(bbox) <- c("min", "max")
    }else
      bbox <- matrix(0, 2, 3)

    # data
    if (missing(df)) df <- data.frame(.dummy = rep(NA, Ndata))

    # end
    new("points3DDataFrame", coords = coords, bbox = bbox, data = df)
  }

#### [ ####
setMethod(
  f = "[",
  signature = "points3DDataFrame",
  definition = function(x,i,j,drop){
    if (missing(i)) i <- seq(nrow(x))
    if (class(i) == "character"){
      j <- i
      i <- seq(nrow(x))
    }
    coords_list <- GetCoords(x)
    df <- GetData(x)
    coords_sub <- coords_list[i]
    df_sub <- df[i,j,drop=FALSE]
    return(points3DDataFrame(coords_sub, df_sub))
  }
)

#### GetCoords ####
#' @rdname GetCoords
setMethod(
  f = "GetCoords",
  signature = "points3DDataFrame",
  definition = function(object, as = c("list", "data.frame", "matrix")){
    as <- as[1]
    if(as == "list"){
      return(object@coords)
    }else if(as == "data.frame"){
      points_list <- object@coords
      df <- t(sapply(points_list, function(x) x))
      df <- as.data.frame(df)
      colnames(df) <- c("X","Y","Z")
      return(df)
    }else if(as == "matrix"){
      points_list <- object@coords
      df <- t(sapply(points_list, function(x) x))
      colnames(df) <- c("X","Y","Z")
      return(df)
    }else{
      stop("Invalid value for 'as' argument")
    }
  }
)

#### setAs ####
setAs("NULL", "points3DDataFrame", function(from, to)
  new(to, list(), data.frame()))
setAs("points3DDataFrame", "data.frame", function(from, to)
  cbind(GetCoords(from, "data.frame"), GetData(from)))


#### rbind, cbind equivalents ####
#' @rdname Bind
setMethod("Bind", c("points3DDataFrame","points3DDataFrame"),
          function(x, y){

            # coordinates
            coords <- rbind(
              GetCoords(x, "matrix"),
              GetCoords(y, "matrix"))
            row.names(coords) <- seq(nrow(coords))

            # data
            datax <- GetData(x)
            datay <- GetData(y)
            all.labels <- unique(c(colnames(datax), colnames(datay)))
            newx <- data.frame(matrix(NA, nrow(x), length(all.labels)))
            newy <- data.frame(matrix(NA, nrow(y), length(all.labels)))
            colnames(newx) <- colnames(newy) <- all.labels
            newx[, colnames(datax)] <- datax
            newy[, colnames(datay)] <- datay
            df <- rbind(newx, newy)

            # # padding with NAs
            # samecolsx <- colnames(datax) %in% colnames(datay)
            # samecolsy <- colnames(datay) %in% colnames(datax)
            # padx <- matrix(NA, nrow(x), sum(!samecolsy))
            # colnames(padx) <- colnames(datay[!samecolsy])
            # pady <- matrix(NA, nrow(y), sum(!samecolsx))
            # colnames(pady) <- colnames(datax[!samecolsx])
            # datax <- cbind(datax, padx)
            # datay <- cbind(datay, pady)

            # ordering columns


            # df <- merge(datax, datay, all=T, sort=F)
            row.names(df) <- seq(nrow(df))
            return(points3DDataFrame(coords,df))
          })

#### Pointify ####
#' @rdname Pointify
setMethod(
  f = "Pointify",
  signature = "points3DDataFrame",
  definition = function(object) object
)

#### DrawPoints ####
#' @rdname DrawPoints
setMethod(
  f = "DrawPoints",
  signature = "points3DDataFrame",
  definition = function(object, by, values, col, size, alpha = 1,
                        col.default = "white", as = c("spheres", "points")){

    # setup
    as <- as[1]
    coords <- GetCoords(object, "matrix")
    df <- GetData(object)
    N <- nrow(object)
    objval <- df[, by]
    if (length(size) < N) size <- rep(size, length.out = N)
    if (length(alpha) < N) alpha <- rep(alpha, length.out = N)

    # pallette
    if (class(objval) == "numeric"){ # continuous variable
      colorsc <- .find_color_cont(objval,
                                 rng = range(values),
                                 col = col, na.color = col.default)
    } else{ # categorical variable
      names(col) <- values
      colorsc <- col[objval]
    }

    # plotting
    if (as == "spheres")
      spheres3d(coords, radius = size/2,
                color = colorsc, alpha = alpha)
    else if (as == "points")
      points3d(coords, color = colorsc)
    else
      stop("Invalid value to 'as' argument")
  }
)

#### DrawTangentPlanes ####
#' @rdname DrawTangentPlanes
setMethod(
  f = "DrawTangentPlanes",
  signature = "points3DDataFrame",
  definition = function(object, size, dip = "Dip", strike = "Strike",
                        col = "yellow"){
    # setup
    N <- nrow(object)
    normalvec <- GetData(GetNormals(object, dip, strike))
    coords <- GetCoords(object, "matrix")
    if (length(col) < N)
      col <- rep(col, length.out = N)

    # drawing planes
    for (i in seq(nrow(object))){
      cylcoords <- rbind(coords[i, ] + normalvec[i, ] * size/1000,
                         coords[i, ] - normalvec[i, ] * size/1000)
      shade3d(
        cylinder3d(cylcoords, radius = size/2,
                   sides = 128, closed = -2),
        col = col[i]
      )
    }
  }
)

