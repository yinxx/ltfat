function [g,a,fc,L]=nonwarpedfilters(freqtoscale,scaletofreq,fs,fmin,fmax,bins,Ls,varargin)
%WARPEDFILTERS   Frequency-warped band-limited filters
%   Usage:  [g,a,fc]=warpedfilters(freqtoscale,scaletofreq,fs,fmin,fmax,bins,Ls);
%
%   Input parameters:
%      freqtoscale  : Function converting frequency (Hz) to scale units
%      scaletofreq  : Function converting scale units to frequency (Hz)
%      fs           : Sampling rate (in Hz).
%      fmin         : Minimum frequency (in Hz)
%      fmax         : Maximum frequency (in Hz)
%      bins         : Vector consisting of the number of bins per octave.
%      Ls           : Signal length.
%   Output parameters:
%      g            : Cell array of filters.
%      a            : Downsampling rate for each channel.
%      fc           : Center frequency of each channel (in Hz).
%      L            : Next admissible length suitable for the generated filters.
%
%   `[g,a,fc]=warpedfilters(freqtoscale,scaletofreq,fs,fmin,fmax,bins,Ls)`
%   constructs a set of band-limited filters *g* which cover the required 
%   frequency range `fmin`-`fmax` with `bins` filters per scale unit. The 
%   filters are always centered at full (fractional $k/bins$) scale units, 
%   where the first filter is selected such that its center is lower than 
%   `fmin`. 
%
%   By default, a Hann window on the frequency side is choosen, but the
%   window can be changed by passing any of the window types from
%   |firwin| as an optional parameter.
%   Run `getfield(getfield(arg_firwin,'flags'),'wintype')` to get a cell
%   array of window types available.
%
%   With respect to the selected scale, all filters have equal bandwidth 
%   and are uniformly spaced on the scale axis, e.g. if `freqtoscale` is 
%   $\log(x)$, then we obtain constant-Q filters with geometric spacing. 
%   The remaining frequency intervals not covered by these filters are 
%   captured one or two additional filters (high-pass always, low-pass if 
%   necessary). The signal length `Ls` is required in order to obtain the 
%   optimal normalization factors.
%   
%   Attention: When using this function, the user needs to be aware of a 
%   number of things: 
%
%       a)  Although the `freqtoscale` and `scaletofreq` can be chosen
%           freely, it is assumed that `freqtoscale` is an invertible,
%           increasing function from $\mathbb{R}$ or $\mathbb{R}^+$ onto
%           $\mathbb{R}$ and that `freqtoscale` is the inverse function.
%       b)  If `freqtoscale` is from $\mathbb{R}^+$ onto $\mathbb{R}$, then
%           necessarily $freqtoscale(0) = -\infty$.
%       c)  If the slope of `freqtoscale` is (locally) too steep, then
%           there is the chance that some filters are effectively $0$ or
%           have extremely low bandwidth (1-3 samples), and consequently
%           very poor localization in time. If `freqtoscale` is from 
%           $\mathbb{R}^+$ onto $\mathbb{R}$ then this usually occurs close
%           to the DC component and can be alleviated by increasing `fmin`.
%       d)  Since the input parameter `bins` is supposed to be integer, 
%           `freqtoscale` and `scaletofreq` have to be scaled
%           appropriately. Note that $freqtoscale(fs)$ is in some sense
%           proportional to the resulting number of frequency bands and
%           inversely proportional to the filter bandwidths. For example,
%           the ERB scale defined by $21.4\log_{10}(1+f/228.8)$ works
%           nicely out of the box, while the similar mel scale
%           $2595\log_{10}(1+f/700)$ most likely has to be rescaled in
%           order not to provide a filter bank with 1000s of channels.
%
%   If any of these guidelines are broken, this function is likely to break
%   or give undesireable results.  
% 
%   By default, a Hann window is chosen as the transfer function prototype, 
%   but the window can be changed by passing any of the window types from
%   |firwin| as an optional parameter.
%
%   The integer downsampling rates of the channels must all divide the
%   signal length, |filterbank| will only work for input signal lengths
%   being multiples of the least common multiple of the downsampling rates.
%   See the help of |filterbanklength|. 
%   The fractional downsampling rates restrict the filterbank to a single
%   length *L=Ls*.
%
%   `[g,a]=warpedfilters(...,'regsampling')` constructs a non-uniform
%   filterbank with integer subsampling factors. 
%
%   `[g,a]=warpedfilters(...,'uniform')` constructs a uniform filterbank
%   where the the downsampling rate is the same for all the channels. This
%   results in most redundant representation, which produces nice plots.
%
%   `[g,a]=warpedfilters(...,'fractional')` constructs a filterbank with
%   fractional downsampling rates *a*. This results in the
%   least redundant system.
%
%   `[g,a]=warpedfilters(...,'fractionaluniform')` constructs a filterbank
%   with fractional downsampling rates *a*, which are uniform for all filters
%   except the "filling" low-pass and high-pass filters can have different
%   fractional downsampling rates. This is usefull when uniform subsampling
%   and low redundancy at the same time are desirable.
%
%   The filters are intended to work with signals with a sampling rate of
%   *fs*.
%
%   `warpedfilters` accepts the following optional parameters:
%
%       'bwmul',bwmul 
%                           Bandwidth variation factor. Multiplies the
%                           calculated bandwidth. Default value is *1*.
%                           If the value is less than one, the
%                           system may no longer be painless.
%
%       'complex'            
%                           Construct a filterbank that covers the entire
%                           frequency range. When missing, only positive
%                           frequencies are covered.
%
%       'redmul',redmul      
%                           Redundancy multiplier. Increasing the value of
%                           this will make the system more redundant by
%                           lowering the channel downsampling rates. Default
%                           value is *1*. If the value is less than one,
%                           the system may no longer be painless.
%
%   Examples:
%   ---------
%
%   In the first example, we use the ERB scale functions `freqtoerb` and
%   `erbtofreq` to construct a filter bank and visualize the result:::
%
%     [s,fs] = gspi; % Get a test signal
%     Ls = numel(gspi);
%
%     % Fix some parameters
%     fmax = fs/2;
%     bins = 1;
%
%     % Compute filters, using fractional downsampling
%     [g,a,fc]=nonwarpedfilters(@freqtoerb,@erbtofreq,fs,0,fmax,2,Ls,...
%                      'bwmul',1,'real','fractional','gauss');
%
%     % Define the frequency-to-scale and scale-to-frequency functions
%     fmin = 50;
%     warpfun_log = @(x) 10*log(x);
%     invfun_log = @(x) exp(x/10);
%
%     [g,a,fc]=nonwarpedfilters(warpfun_log,invfun_log,fs,fmin,fmax,1,Ls,...
%                      'bwmul',1,'real','fractional','gauss');
%
%
%     fmin = 0;
%     warpfun_sq = @(x) sign(x).*((1+abs(x)/4).^(1/2)-1);
%     invfun_sq = @(x) 4*sign(x).*((1+abs(x)).^2-1);
%
%     [g,a,fc]=nonwarpedfilters(warpfun_sq,invfun_sq,fs,fmin,fmax,1,Ls,...
%                      'bwmul',1,'real','fractional','gauss');
%
%     warpfun_4 = @(x) 8*sign(x).*((1+abs(x)).^(1/4)-1);
%     invfun_4 = @(x) sign(x).*((1+abs(x)/8).^4-1);
%
%     [g,a,fc]=nonwarpedfilters(warpfun_4,invfun_4,fs,fmin,fmax,1,Ls,...
%                      'bwmul',1,'real','fractional','gauss');
%
%
%   See also: erbfilters, cqtfilters, firwin, filterbank, warpedblfilter
%
%   References: ltfatnote039
%

% Authors: Nicki Holighaus, Zdenek Prusa
% Date: 14.01.15 

%% Check input arguments
capmname = upper(mfilename);
complainif_notenoughargs(nargin,7,capmname);
complainif_notposint(fs,'fs',capmname);
complainif_notposint(fmin+1,'fmin',capmname);
complainif_notposint(fmax,'fmax',capmname);
complainif_notposint(bins,'bins',capmname);
complainif_notposint(Ls,'Ls',capmname);

if ~isa(freqtoscale,'function_handle')
    error('%s: freqtoscale must be a function handle',capmname)
end

if ~isa(scaletofreq,'function_handle')
    error('%s: scaletofreq must be a function handle',capmname)
end

if fmin>=fmax
    error('%s: fmin has to be less than fmax.',capmname);
end


firwinflags=getfield(arg_firwin,'flags','wintype');
freqwinflags=getfield(arg_freqwin,'flags','wintype');

definput.flags.wintype = [ firwinflags, freqwinflags];
definput.keyvals.bwmul = 1;
definput.keyvals.redmul = 1;
definput.keyvals.min_win = 1;
definput.keyvals.trunc_at=10^(-5);
definput.flags.real     = {'real','complex'};
definput.flags.sampling = {'regsampling','uniform',...
                           'fractional','fractionaluniform'};
                       
% Search for window given as cell array
candCellId = cellfun(@(vEl) iscell(vEl) && any(strcmpi(vEl{1},definput.flags.wintype)),varargin);

winCell = {};
% If there is such window, replace cell with function name so that 
% ltfatarghelper does not complain
if ~isempty(candCellId) && any(candCellId)
    winCell = varargin{candCellId(end)};
    varargin{candCellId} = [];
    varargin{end+1} = winCell{1};
end

[flags,kv]=ltfatarghelper({},definput,varargin);
if isempty(winCell), winCell = {flags.wintype}; end

if ~isscalar(kv.bwmul)
    error('%s: bwmul must be scalar',capmname)
end

if ~isscalar(kv.redmul)
    error('%s: redmul must be scalar',capmname)
end

if ~isscalar(kv.min_win)
    error('%s: min_win must be scalar',capmname)
end

probelen = 10000;

switch flags.wintype
    case firwinflags
        winbw=norm(firwin(flags.wintype,probelen)).^2/probelen; 
        filterfunc = @(fsupp,fc,scal)... 
                     blfilter(winCell,fsupp,fc,'fs',fs,'scal',scal,...
                     'inf','min_win',kv.min_win);
        
        bwtruncmul = 1;
    case freqwinflags
        
        probebw = 0.01;
        H = freqwin(winCell,probelen,probebw);
        winbw = norm(H).^2/(probebw*probelen/2);
        % Determine where to truncate the window
        bwrelheight = 10^(-3/10);

        if kv.trunc_at <= eps
            bwtruncmul = inf;
        else
            try
                bwtruncmul = winwidthatheight(abs(H),kv.trunc_at)/winwidthatheight(abs(H),bwrelheight);
            catch
                bwtruncmul = inf;
            end
        end

        filterfunc = @(fsupp,fc,scal)...
                     freqfilter(winCell, fsupp, fc,'fs',fs,'scal',scal,...
                                'inf','min_win',kv.min_win,...
                                'bwtruncmul',bwtruncmul);       
end

% Nyquist frequency
nf = fs/2;

% Limit fmax
if fmax > nf
    fmax = nf;
end
% Limit fmin
if fmin <= 0 && freqtoscale(0) == -Inf
    fmin = scaletofreq(freqtoscale(1));
end

%Determine range/number of windows
chan_min = floor(bins*freqtoscale(fmin))/bins;
if chan_min >= fmax;
    error('%s: Invalid frequency scale, try lowering fmin',...
          upper(mfilename));
end
chan_max = chan_min;
while scaletofreq(chan_max) <= fmax
    chan_max = chan_max+1/bins;
end
while scaletofreq(chan_max+kv.bwmul) >= nf
    chan_max = chan_max-1/bins;
end

% Prepare frequency centers in Hz
scalevec = (chan_min:1/bins:chan_max)';
fc = [scaletofreq(scalevec);nf];
if fmin~=0 
    fc = [0;fc];
end

M = length(fc);
%% ----------------------------------
% Set bandwidths
fsupp = zeros(M,1);

% Bandwidth of the low-pass filter around 0 (Check whether floor and/or +1
% is sufficient!!!)
fsuppIdx = 1;
if fmin~=0
    fsupp(1) = ceil(2*scaletofreq(chan_min-1/bins+.5*kv.bwmul))+2;
    bw(1) = fsupp(1);
    fsuppIdx = 2;
end
bw(fsuppIdx:M-1) = (scaletofreq(scalevec+.5*kv.bwmul)-scaletofreq(scalevec-.5*kv.bwmul))/winbw;
fsupp(fsuppIdx:M-1) = ceil(bw(fsuppIdx:M-1))+2;
fsupp(M) = ceil(2*(nf-scaletofreq(chan_max+1/bins-.5*kv.bwmul)))+2;
bw(M) = fsupp(M);

% Find suitable channel subsampling rates
% Do not apply redmul to channels 1 and M as it produces uneccesarily
% badly conditioned frames
aprecise=fs./fsupp;
aprecise(2:end-1)=aprecise(2:end-1)/kv.redmul;
aprecise=aprecise(:);
if any(aprecise<1)
    error('%s: The maximum redundancy mult. for this setting is %5.2f',...
         upper(mfilename), min(fs./fsupp));
end

%% Compute the downsampling rate
if flags.do_regsampling
    % Shrink "a" to the next composite number
    a=floor23(aprecise);

    % Determine the minimal transform length
    L=filterbanklength(Ls,a);

    % Heuristic trying to reduce lcm(a)
    while L>2*Ls && ~(all(a==a(1)))
        maxa = max(a);
        a(a==maxa) = 0;
        a(a==0) = max(a);
        L = filterbanklength(Ls,a);
    end

elseif flags.do_fractional
    L = Ls;
    N=ceil(Ls./aprecise);
    a=[repmat(Ls,M,1),N];
elseif flags.do_fractionaluniform
    L = Ls;
    N=ceil(Ls./min(aprecise));
    a= repmat([Ls,N],M,1);
elseif flags.do_uniform
    a=floor(min(aprecise));
    L=filterbanklength(Ls,a);
    a = repmat(a,M,1);
end;

% Get an expanded "a"
afull=comp_filterbank_a(a,M,struct());

%% Compute the scaling of the filters
% Individual filter peaks are made square root of the subsampling factor
scal=sqrt(afull(:,1)./afull(:,2));

if flags.do_real
    % Scale the first and last channels
    scal(1)=scal(1)/sqrt(2);
    scal(M)=scal(M)/sqrt(2);
else
    % Replicate the centre frequencies and sampling rates, except the first and
    % last
    a=[a;flipud(a(2:M-1,:))];
    scal=[scal;flipud(scal(2:M-1))];
    fc  =[fc; -flipud(fc(2:M-1))];
    fsupp=[fsupp;flipud(fsupp(2:M-1))];
end;

g = cell(1,numel(fc));

gIdxStart = 1;
if fmin~=0
    % Low-pass filter
    g{1} = zerofilt(flags.wintype,fs,chan_min,freqtoscale,scaletofreq,scal(1),kv.bwmul,bins,Ls);
    gIdxStart = gIdxStart + 1;
end

% High-pass filter
g{M} = nyquistfilt(flags.wintype,fs,chan_max,freqtoscale,scaletofreq,scal(M),kv.bwmul,bins,Ls);

%symmetryflag = 'nonsymmetric';
%if freqtoscale(0) < -1e10, symmetryflag = 'symmetric'; end;

% All the other filters
for gIdx = [gIdxStart:M-1,M+1:numel(fc)]
   g{gIdx}=filterfunc(bw(gIdx),fc(gIdx),scal(gIdx));
end


function g = nyquistfilt(wintype,fs,chan_max,freqtoscale,scaletofreq,scal,bwmul,bins,Ls)
    % This function constructs a high-pass filter centered at the Nyquist
    % frequency such that the summation properties of the filter bank
    % remain intact.
    g=struct();
    
    % Inf normalization as standard
    g.H = @(L) comp_nyquistfilt('hann',fs,chan_max,freqtoscale,scaletofreq,bwmul,bins,Ls)*scal;
    
    g.foff=@(L) floor(L/2)+1-(numel(g.H(L))+1)/2;
    g.fs=fs;


function g = zerofilt(wintype,fs,chan_min,freqtoscale,scaletofreq,scal,bwmul,bins,Ls)
    % This function constructs a low-pass filter centered at the zero
    % frequency such that the summation properties of the filter bank
    % remain intact.
    g=struct();
    
    % Inf normalization as standard
    g.H = @(L) comp_zerofilt('hann',fs,chan_min,freqtoscale,scaletofreq,bwmul,bins,Ls)*scal;
    
    g.foff=@(L) -(numel(g.H(L))+1)/2+1;
    g.fs=fs;