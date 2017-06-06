function NEIGH = comp_nufbneighbors(a,M,N)

%M = numel(c);

chanStart = [0;cumsum(N)];

NEIGH = zeros(6,chanStart(end));

%Horizontal neighbors
for kk = 1:M
  NEIGH(1,chanStart(kk)+1) = chanStart(kk)+2; 
  NEIGH(1,chanStart(kk+1)) = chanStart(kk+1)-1;
  NEIGH(1:2,chanStart(kk)+(2:N(kk)-1)) = chanStart(kk)+[(1:N(kk)-2);(3:N(kk))];
end

%Vertical neighbors
%Set time distance limit
LIM = .8;

%One channel higher
for kk = 1:M-1
  aTemp = a(kk)/a(kk+1);
  POSlow = chanStart(kk+1)+max(0,ceil(((0:N(kk)-1)-LIM)*aTemp));
  POShigh = chanStart(kk+1)+min(floor(((0:N(kk)-1)+LIM)*aTemp),N(kk+1)-1);
  
%   for ll = 1:N(kk)
%     tmpIdx = (POSlow(ll):POShigh(ll))+1;    
%     NEIGH((5:4+numel(tmpIdx)),chanStart(kk)+ll) = tmpIdx.';
%   end

NEIGH(5,chanStart(kk)+(1:N(kk))) = POSlow + 1;
NEIGH(6,chanStart(kk)+(1:N(kk))) = POShigh + 1;
end

NEIGH(6,NEIGH(6,:)==NEIGH(5,:)) = 0;

%One channel lower
for kk = 2:M
  aTemp = a(kk)/a(kk-1);  
  POSlow = chanStart(kk-1)+max(0,ceil(((0:N(kk)-1)-LIM)*aTemp))';
  POShigh = chanStart(kk-1)+min(floor(((0:N(kk)-1)+LIM)*aTemp),N(kk-1)-1)';
  
%   for ll = 1:N(kk)
%     tmpIdx = (POSlow(ll):POShigh(ll))+1;    
%     NEIGH((3:2+numel(tmpIdx)),chanStart(kk)+ll) = tmpIdx.';
%   end
NEIGH(3,chanStart(kk)+(1:N(kk))) = POSlow + 1;
NEIGH(4,chanStart(kk)+(1:N(kk))) = POShigh + 1;
end
NEIGH(4,NEIGH(4,:)==NEIGH(3,:)) = 0;

end