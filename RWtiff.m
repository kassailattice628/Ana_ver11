function stack=RWtiff(varargin)

% parse input arguments
if nargin==0
	[file1,path1]=uigetfile({'*.tiff';'*.tif'},'Select Tiff Image'...
    ,'~/Desktop');
	f= sprintf('%s/%s',path1,file1);
elseif nargin==1
	f=varargin{1};
else
	disp('To many input arguments');
	disp('Usage: stack = tiffread3 or stack = tiffread3(inputFilePath)');
	return;
end

disp(['Reading ', f, ' ...']);
%write data to stack
tmp=tiffread(f);
tmpim=tmp(1).data;
stack=zeros(size(tmpim,1),size(tmpim,2),length(tmp));
for N=1:length(tmp)
    stack(:,:,N)=tmp(N).data;
end
disp('Done')

