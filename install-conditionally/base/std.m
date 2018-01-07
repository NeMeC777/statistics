## Copyright (C) 1996-2017 John W. Eaton
##
## This program is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {} {} std (@var{x})
## @deftypefnx {} {} std (@var{x}, @var{opt})
## @deftypefnx {} {} std (@var{x}, @var{opt}, @var{dim})
## Compute the standard deviation of the elements of the vector @var{x}.
##
## The standard deviation is defined as
## @tex
## $$
## {\rm std} (x) = \sigma = \sqrt{{\sum_{i=1}^N (x_i - \bar{x})^2 \over N - 1}}
## $$
## where $\bar{x}$ is the mean value of $x$ and $N$ is the number of elements.
## @end tex
## @ifnottex
##
## @example
## @group
## std (x) = sqrt ( 1/(N-1) SUM_i (x(i) - mean(x))^2 )
## @end group
## @end example
##
## @noindent
## where @math{N} is the number of elements.
## @end ifnottex
##
## If @var{x} is a matrix, compute the standard deviation for each column and
## return them in a row vector.
##
## The argument @var{opt} determines the type of normalization to use.
## Valid values are
##
## @table @asis
## @item 0:
##   normalize with @math{N-1}, provides the square root of the best unbiased
## estimator of the variance [default]
##
## @item 1:
##   normalize with @math{N}, this provides the square root of the second
## moment around the mean
## @end table
##
## If the optional argument @var{dim} is given, operate along this dimension.
## @seealso{var, range, iqr, mean, median}
## @end deftypefn

## Author: jwe

function retval = std (x, opt = 0, dim)

  if (nargin < 1 || nargin > 3)
    print_usage ();
  endif

  if (! (isnumeric (x) || islogical (x)))
    error ("std: X must be a numeric vector or matrix");
  endif

  if (isempty (opt))
    opt = 0;
  elseif (! isscalar (opt) || (opt != 0 && opt != 1))
    error ("std: normalization OPT must be 0 or 1");
  endif

  nd = ndims (x);
  sz = size (x);
  if (nargin < 3)
    ## Find the first non-singleton dimension.
    (dim = find (sz > 1, 1)) || (dim = 1);
  else
    if (! (isscalar (dim) && dim == fix (dim) && dim > 0))
      error ("std: DIM must be an integer and a valid dimension");
    endif
  endif

  n = size (x, dim);
  if (n == 1 || isempty (x))
    if (isa (x, "single"))
      retval = zeros (sz, "single");
    else
      retval = zeros (sz);
    endif
  else
    retval = sqrt (sumsq (center (x, dim), dim) / (n - 1 + opt));
  endif

endfunction


%!test
%! x = ones (10, 2);
%! y = [1, 3];
%! assert (std (x), [0, 0]);
%! assert (std (y), sqrt (2), sqrt (eps));
%! assert (std (x, 0, 2), zeros (10, 1));

%!assert (std (ones (3, 1, 2), 0, 2), zeros (3, 1, 2))
%!assert (std ([1 2], 0), sqrt (2)/2, 5*eps)
%!assert (std ([1 2], 1), 0.5, 5*eps)
%!assert (std (1), 0)
%!assert (std (single (1)), single (0))
%!assert (std ([]), [])
%!assert (std (ones (1,3,0,2)), ones (1,3,0,2))
%!assert (std ([1 2 3], [], 3), [0 0 0])

## Test input validation
%!error std ()
%!error std (1, 2, 3, 4)
%!error <X must be a numeric> std (['A'; 'B'])
%!error <OPT must be 0 or 1> std (1, 2)
%!error <DIM must be an integer> std (1, [], ones (2,2))
%!error <DIM must be an integer> std (1, [], 1.5)
%!error <DIM must be .* a valid dimension> std (1, [], 0)
