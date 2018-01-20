% CSCI 631: Foundations of Computer Vision
%
% Project Title: Image Denoising using Wavelet Shrinkage
%
% Created by: Dhaval Chauhan (dmc8686@rit.edu)
% Created by: Anuja Vane (asv1612@rit.edu)
%                   Computer Science Department
%                   Rochester Institute of Technology
%
% Created on: 23, November, 2017
%
% A program to denoise's a noisy input image using Wavelet Shrinkage.
% NO ARTIFICIAL GAUSSIAN NOISE IS INTRODUCED IN THIS PROGRAM.
% This program assumes that the input image has at least 12 Megapixel
% resolution.


% This function takes in path of an noisy image file, denoise's it using
% Wavelet Shrinkage, and displays them.
function DenoiseYourOwnImageUsingWaveletShrinkage( noisy_input_image_path )
    
    % Read input image. ( Assumption is that input image is Color )
    im                  = imread( noisy_input_image_path );
    im_r                = im(:,:,1);
    im_g                = im(:,:,2);
    im_b                = im(:,:,3);
    
    % Consider all 3 channels have noise in them.
    % ( Assumption is that input image is already noisy )
    im_noise_r          = im_r;
    im_noise_g          = im_g;
    im_noise_b          = im_b;

    % Combine noisy channels in 1 image.
    im_noise            = im;
    im_noise(:,:,1)     = im_noise_r;
    im_noise(:,:,2)     = im_noise_g;
    im_noise(:,:,3)     = im_noise_b;

    % Define a wavelet variable that uses a Bi-orthogonal wavelet with
    % 5 vanishing levels and 3 reconstruction levels.
    wavelet_name        = 'bior3.5';
    
    % Number of decomposition levels
    decomposition_level = 24;
    
    % Do wavelet decomposition after converting the noisy image to
    % Bi-orthogonal wavelet domain and get the decomposition
    % vector.
    [decomp_vector_r, S_r]  = wavedec2( im_noise_r, decomposition_level, wavelet_name );
    [decomp_vector_g, S_g]  = wavedec2( im_noise_g, decomposition_level, wavelet_name );
    [decomp_vector_b, S_b]  = wavedec2( im_noise_b, decomposition_level, wavelet_name );

    % Get a 2D level dependent threshold using the penalhi method.
    threshold_r          = wthrmngr( 'dw2ddenoLVL', 'penalhi', decomp_vector_r, S_r, 9);
    threshold_g          = wthrmngr( 'dw2ddenoLVL', 'penalhi', decomp_vector_g, S_g, 9);
    threshold_b          = wthrmngr( 'dw2ddenoLVL', 'penalhi', decomp_vector_b, S_b, 9);
    
    % set threshold type as Soft Threshold
    sorh                = 's';
    
    % Get a denoised image using the above threshold of type Soft.
    [im_ws_r_s, CXC, LXC]   = wdencmp('lvd', decomp_vector_r, S_r, ...
                            wavelet_name, decomposition_level, threshold_r,sorh);
    [im_ws_g_s, CXC, LXC]   = wdencmp('lvd', decomp_vector_g, S_g, ...
                            wavelet_name, decomposition_level, threshold_g,sorh);
    [im_ws_b_s, CXC, LXC]   = wdencmp('lvd', decomp_vector_b, S_b, ...
                            wavelet_name, decomposition_level, threshold_b,sorh);

    % set threshold type as Hard Threshold  
    sorh                = 'h';
    
    % Get a denoised image using the above threshold of type Hard.
    [im_ws_r_h, CXC, LXC]   = wdencmp('lvd', decomp_vector_r, S_r, ...
                            wavelet_name, decomposition_level, threshold_r,sorh);
    [im_ws_g_h, CXC, LXC]   = wdencmp('lvd', decomp_vector_g, S_g, ...
                            wavelet_name, decomposition_level, threshold_g,sorh);
    [im_ws_b_h, CXC, LXC]   = wdencmp('lvd', decomp_vector_b, S_b, ...
                            wavelet_name, decomposition_level, threshold_b,sorh);

    % Merge all the soft thresholded channels to 1 3D image.
    im_ws_s             = im;
    im_ws_s(:,:,1)      = im_ws_r_s;
    im_ws_s(:,:,2)      = im_ws_g_s;
    im_ws_s(:,:,3)      = im_ws_b_s;

    % Merge all the hard thresholded channels to 1 3D image.
    im_ws_h             = im;
    im_ws_h(:,:,1)      = im_ws_r_h;
    im_ws_h(:,:,2)      = im_ws_g_h;
    im_ws_h(:,:,3)      = im_ws_b_h;

    % Display original input image
    figure();
    imshow(im);
    title('Original Image');

    % Display image with hard threshold denoising.
    figure();
    imshow(im_ws_h);
    title('Wavelet Shrinkage using a hard threshold');

    % Display image with soft threshold denoising.
    figure();
    title('Wavelet Shrinkage using a soft threshold');
    imshow(im_ws_s);
end

