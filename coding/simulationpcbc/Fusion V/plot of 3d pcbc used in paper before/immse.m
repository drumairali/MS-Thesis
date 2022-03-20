
function [mse] = immse (x, y)

  if (nargin != 2)
    print_usage ();
  elseif (! size_equal (x, y))
    error ("immse: X and Y must be of same size");
  elseif (! strcmp (class (x), class (y)))
    error ("immse: X and Y must have same class");
  end

  if (isinteger (x))
    x = double (x);
    y = double (y);
  endif

  err = x - y;
  mse = sumsq (err(:)) / numel (err);

endfunction