
function xwrap = wrapTo2Pi(x)

  xwrap = rem (x-pi, 2*pi);
  idx = find (abs (xwrap) > pi);
  xwrap(idx) -= 2*pi * sign (xwrap(idx));
  xwrap += pi;

endfunction