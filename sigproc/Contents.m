% LTFAT - Signal processing tools
%
%  Peter L. Søndergaard, 2007 - 2015.
%
%  General
%    RMS            -  Root Mean Square norm of signal.
%    NORMALIZE      -  Normalize signal by specified norm.
%    GAINDB         -  Scale input signal
%    CRESTFACTOR    -  Compute the crest factor of a signal.
%    UQUANT         -  Simulate uniform quantization.
%
%  Window functions
%    FIRWIN         -  FIR windows (Hanning,Hamming,Blackman,...).
%    FIRKAISER      -  FIR Kaiser-Bessel window.
%    FIR2LONG       -  Extend FIR window to LONG window.
%    LONG2FIR       -  Cut LONG window to FIR window.
%
%  Filtering
%    FIRFILTER      -  Construct an FIR filter.
%    BLFILTER       -  Construct a band-limited filter.
%    WARPEDBLFILTER -  Warped, band-limited filter.
%    PFILT          -  Apply filter with periodic boundary conditions.
%    MAGRESP        -  Magnitude response plot.
%    TRANSFERFUNCTION - Compute the transfer function of a filter.
%    PGRPDELAY      -  Periodic Group Delay
%
%  Ramping
%    RAMPUP         -  Rising ramp.
%    RAMPDOWN       -  Falling ramp.
%    RAMPSIGNAL     -  Ramp a signal.
%
%  Thresholding methods
%    THRESH         -  Coefficient thresholding.
%    LARGESTR       -  Keep largest ratio of coefficients.
%    LARGESTN       -  Keep N largest coefficients.
%    DYNLIMIT       -  Limit the dynamical range.
%    GROUPTHRESH    -  Group thresholding.
%
%  Image processing
%    RGB2JPEG       -  Convert RGB values to the JPEG colour model
%    JPEG2RGB       -  Convert values from the JPEG colour model to RGB
%
%  Tools for OFDM
%    QAM4           -  Quadrature amplitude modulation, order 4
%    IQAM4          -  Inverse QAM of order 4
%
%  For help, bug reports, suggestions etc. please send email to
%  ltfat-help@lists.sourceforge.net
%
