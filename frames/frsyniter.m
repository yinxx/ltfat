function [f,relres,iter]=frsyniter(F,c,varargin)
%FRSYNITER  Iterative analysis frame inversion
%   Usage:  f=frsyniter(F,c);
%
%   Input parameters:
%         F       : Frame   
%         c       : Array of coefficients.
%         Ls      : length of signal.
%   Output parameters:
%         f       : Signal.
%         relres  : Vector of residuals.
%         iter    : Number of iterations done.
%
%   `f=frsyniter(F,c)` iteratively inverts the analysis frame of *F* using a
%   least-squares method.
%
%   `[f,relres,iter]=frsyniter(...)` additionally returns the residuals in a
%   vector *relres* and the number of iteration steps *iter*.
%  
%   **Note:** If it is possible to explicitly calculate the canonical dual
%   frame then this is usually a much faster method than invoking
%   `frsyniter`.
%
%   `frsyniter` takes the following parameters at the end of the line of
%   input arguments:
%
%     'tol',t      Stop if relative residual error is less than the
%                  specified tolerance. Default is 1e-9 
%
%     'maxit',n    Do at most n iterations.
%
%     'unlocbox'   Use unlocbox. This is the default.
%
%     'lsqr'       Use the Matlab `lsqr`function.
%
%     'print'      Display the progress.
%
%     'quiet'      Don't print anything, this is the default.
%
%   Examples
%   --------
%
%   The following example shows how to rectruct a signal without ever
%   using the dual frame:::
%
%      F=newframe('dgtreal','gauss','none',10,20);
%      c=frana(F,bat);
%      r=frsyniter(F,c);
%      norm(bat-r)/norm(bat)
%
%   See also: newframe, frana, frsyn
  
% AUTHORS: Nathanael Perraudin and Peter L. Soendergaard
    
  if nargin<2
    error('%s: Too few input parameters.',upper(mfilename));
  end;
  
  definput.keyvals.Ls=[];
  definput.keyvals.tol=1e-6;
  definput.keyvals.maxit=100;
  definput.flags.alg={'unlocbox','lsqr'};
  definput.keyvals.printstep=10;
  definput.flags.print={'quiet','print'};

  [flags,kv,Ls]=ltfatarghelper({'Ls'},definput,varargin);
  
  % Determine L from the first vector, it must match for all of them.
  L=framelengthcoef(F,size(c,1));
    
  
  if flags.do_lsqr
      % Set up the persisten variable
      afun(1, 'dummy', F);
      
      % It is possible to specify the initial guess
      [f,flag,~,iter,relres]=lsqr(@afun,c,kv.tol,kv.maxit);
      
  end;
  
  if flags.do_unlocbox

      % Get the upper frame bound (Or an estimation bigger than the bound)
      [~,B]=framebounds(F,L,'a'); 
      
      % Set the parameter for the fast projection on a B2 ball
      param.At=@(x) franaadj(F,x);  % adjoint operator
      param.A=@(x)  frana(F,x);     % direct operator
      param.y=c;                    % coefficient
      param.tight=0;                % It's not a tight frame
      param.max_iter=kv.maxit;
      param.tol=kv.tol; 
      param.nu=B;
      
      % Display parameter 0 nothing, 1 summary at convergence, 2 all
      % steps
      if flags.do_print
          param.verbose=1;
      else
          param.verbose=0;
      end;
      
      % Make the projection. Requires UNLocBOX
      [f, ~] = fast_proj_B2(zeros(L,1), 0, param);
      
      % compute the residue
      res = param.A(f) - param.y; norm_res = norm(res(:), 2);
      relres=norm_res/norm(c(:), 2);
      
      iter=0; % The code of the fast_proj_B2 is not yet compatible with this
  end;
      
  % Cut or extend f to the correct length, if desired.
  if ~isempty(Ls)
      f=postpad(f,Ls);
  else
      Ls=L;
  end;
      
end

% This is a nested function, as it must use variables from the scope
% or the main function
function y=afun(x, transp_flag, F_in)
  persistent F;

  if nargin>2
    F  = F_in; 
  else  
    if strcmp(transp_flag,'transp') 
      y = franaadj(F,x);    
    elseif strcmp(transp_flag,'notransp')
      y = frana(F,x);    
    end 
  end
end
  
    