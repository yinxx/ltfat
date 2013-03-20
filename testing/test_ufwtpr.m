function test_failed = test_ufwtpr(verbose)
%TEST_COMP_FWT_ALL
%
% Checks perfect reconstruction of the wavelet transform of different
% filters
%
test_failed = 0;
if(nargin>0)
   verbose = 1;
   which comp_ufwt -all
   which comp_iufwt -all
else
   verbose = 0;
end

%  curDir = pwd;
%  mexDir = [curDir(1:strfind(pwd,'\ltfat')+5),'\mex'];
% 
%  rmpath(mexDir);
%  which comp_fwt_all
%  addpath(mexDir)
%  which comp_fwt_all


type = {'undec'};
ext = {'per'};

prefix = 'wfilt_';
test_filters = {
               {'db',1}
               {'db',3}
               {'db',10}
               {'spline',4,4}
               %{'lemaire',80} % not exact reconstruction
               {'hden',3} % only one with 3 filters and different
               %subsampling factors, not working
               {'algmband',2} % 4 filters, subsampling by the factor of 4!, really long identical lowpass filter
               %{'symds',1}
               {'algmband',1} % 3 filters, sub sampling factor 3, even length
               {'sym',4}
               {'sym',9}
               %{'symds',2}
%               {'symds',3}
%               {'symds',4}
%               {'symds',5}
               {'spline',3,5}
               {'spline',3,11}
               {'spline',11,3}
               %{'maxflat',2}
               %{'maxflat',11}
               %{'optfs',7} % bad precision of filter coefficients
               %{'remez',20,10,0.1} % no perfect reconstruction
               {'dden',1}
               {'dden',2}
               {'dden',3}
               {'dden',4}
               {'dden',5}
               {'dden',6}
               {'dden',7}
               {'dgrid',1}
               {'dgrid',2}
               {'dgrid',3}
               %{'algmband',1} 
               {'mband',1}
               %{'hden',3}
               %{'hden',2}
               %{'hden',1}
               %{'algmband',2}
               %{'apr',1} % complex filter values, odd length filters, no perfect reconstruction
               };
%ext = {'per','zpd','sym','symw','asym','asymw','ppd','sp0'};


J = 4;
%testLen = 10*2^J-1;%(2^J-1);
testLen = 1589;

for extIdx=1:length(ext)  
%for inLenRound=0:2^J-1
for inLenRound=0:0
%f = randn(14576,1);
f = randn(testLen+inLenRound,1);
%f = 1:testLen-1;f=f';
%f = 0:30;f=f';
% multiple channels
%f = [2*f,f,0.1*f];
    
for typeIdx=1:length(type)
  typeCur = type{typeIdx};

     extCur = ext{extIdx};  
     
     
     for tt=1:length(test_filters)
         actFilt = test_filters{tt};
         %fname = strcat(prefix,actFilt{1});
         %w = fwtinit(test_filters{tt});  

     for jj=1:J
           if verbose, fprintf('J=%d, filt=%s, inLen=%d\n',jj,actFilt{1},length(f)); end; 
           
           c = ufwt(f,test_filters{tt},jj);
           %[cvec ,Lc] = cell2pack(c);
           %c = pack2cell(cvec,Lc);
            fhat = iufwt(c,test_filters{tt},jj);
            err = norm(f(:)-fhat(:));
            if err>1e-6
               test_failed = 1; 
               if verbose
                 fprintf('err=%d, J=%d, filt=%s, inLen=%d',err,jj,actFilt{1},testLen+inLenRound);
                 figure(1);clf;stem([f,fhat]);
                 figure(2);clf;stem([f-fhat]);
               end
               break; 
            end
     end
      if test_failed, break; end;
     end
     if test_failed, break; end;
  end 
   if test_failed, break; end;
end
 if test_failed, break; end;
end

 
 
   
