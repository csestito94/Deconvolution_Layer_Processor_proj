%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FINAL TEST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
clc;

% Define test ifmap and coefficients.
H = 32;
W = 32;
IF1 = ones(H,W);
IF2 = ones(H,W);
IF3 = ones(H,W);
COEFF = [1 2 3 4 5; 1 2 3 4 5; 1 2 3 4 5; 1 2 3 4 5; 1 2 3 4 5];

% Perform 2D transposed convolution. 
K = 5;
S = 2;
P = 0;
PF1 = deConv2D(IF1,COEFF,S,P);
PF2 = deConv2D(IF2,COEFF,S,P);
PF3 = deConv2D(IF3,COEFF,S,P);

% Accumulate channel provisional results.
OH = S*(H-1)+K-2*P;
OW = S*(W-1)+K-2*P;
OF = PF1+PF2+PF3;
OF = reshape(transpose(OF),[OH*OW 1]);

% Read results provided by VIVADO SDK and arrange them for testing.
sdk_file = fopen('results.txt', 'r');
RES = textscan(sdk_file,'%s %s','Delimiter',':');
fclose(sdk_file);
RES = cell2mat(RES{2});
RESA = hex2dec(RES(:,[7,8]));
RESB = hex2dec(RES(:,[3,4]));
RES = zeros(OH*(OW+1),1);
ca = 1;
cb = 1;
for i = 1:OH*(OW+1)
    if rem(i,2)~=0
        RES(i) = RESA(ca);
        ca=ca+1;
    else
        RES(i) = RESB(cb);
        cb=cb+1;
    end
end
indices = OW+1:OW+1:length(RES);
RES(indices)=[];

% Test
EQUALITY = isequal(OF,RES);
disp('Test result: 1(OK)/0(NO)');
disp(EQUALITY);








        

