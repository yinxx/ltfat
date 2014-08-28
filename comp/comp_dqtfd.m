function p = comp_dqtfd(f, q, Ls);
% Comp_DQTFD Compute discrete quadratic time-frequency distribution
%   Usage p = comp_dqtfd(f, q, Ls);
%
%   Input parameters:
%         f      : Input signal
%	  q	 : Kernel
%	  L 	 : length of f
%
%   Output parameters:
%         p      : discrete quadratic time-frequency distribution
%

% AUTHOR: Jordy van Velthoven

if isreal(f)
 z = comp_anarep(f, Ls);
else
 z = f;
endif;

i = comp_iaf(z, Ls);

c = fftshift(ifft2(fft2(i).*fft2(q)));

p = 2*fft(c);