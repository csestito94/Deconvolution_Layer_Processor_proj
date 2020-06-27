%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% 2D ARRAY TRANSPOSED CONVOLUTION %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This function implements the transposed convolution algorithm,
%   according to the CPU-based approach:
%   1. Stride the input 2D array by a S factor.
%   2. Pad the strided input according to the expression P' = K-P-1.
%   3. Convolve the conv-like arranged input by a K*K kernel.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function deconv_array = deConv2D(array2D,kernel2D,S,P)
    K = size(kernel2D,1);
    strided_array = array2DStriding(array2D,S);
    padded_array = array2DPadding(strided_array,K,P);
    deconv_array = conv2(padded_array,kernel2D,'valid');
end