% CSCI 631: Foundations of Computer Vision
%
% Project Title: Image Denoising using Wavelet Shrinkage
%
% Created by: Dhaval Chauhan (dmc8686@rit.edu)
% Created by: Anuja Vane (asv1612@rit.edu)
%                   Computer Science Department
%                   Rochester Institute of Technology
%
% Created on: 21, November, 2017
%
% A program to see comparisons between multiple noise reduction techniques.
% User will pass path of a clean image and this program will add noise to
% it and then denoise it for the user to see the difference between
% performance of multiple methods.


% This function takes in path of an image file, checks whether its a color
% image or a grayscale image, and calls a function that does wavelet
% shrinkage function on the input image.
function WaveletShrinkageTest( input_image_path )
    
    % Read in the input image.
    im                  = imread( input_image_path );
    
    % Get the dimensions of the input image.
    dims                = size( im );
    
    % Check if it a color or a grayscale image and call the denoise
    % function.
    if ( length(dims) > 2 )
        
        % Call denoise method for a color image.
        wavelet_denoise( im, 'c' );
    else
        
        % Call denoise method for a grayscale image.
        wavelet_denoise( im, 'g' );
    end
end

% This function performs denoising on the input image and shows the output
% results of all the denoising method.
function wavelet_denoise( im , color_or_gray )

    % If the image is in grayscale.
    if color_or_gray == 'g'
        
        % Introduce Gaussian noise with mean 0 and standard deviation 0.01
        im_noise            = imnoise( im, 'gaussian', 0, 0.01 );
        
        % Do median filtering on the noisy image.
        im_median_fltrd     = medfilt2( im_noise );
        
        % Create a Gaussian filter of size 3 and standard deviation 5.
        fltr                = fspecial( 'gaussian', 3, 5 ); 
        
        % Filter the noisy image using the gaussian filter matrix obtained
        % above.
        im_lclavg_fltrd     = imfilter( im_noise, fltr, 'same', 'repl' );
        
        % Define a wavelet variable that uses a Bi-orthogonal wavelet with
        % 5 vanishing levels and 3 reconstruction levels.
        wavelet_name        = 'bior3.5';
        
        % Number of decomposition levels
        decomposition_level = 5;
        
        % Do wavelet decomposition after converting the noisy image to
        % Bi-orthogonal wavelet domain and get the decomposition
        % vector.
        [decomp_vector, S]  = wavedec2( im_noise, decomposition_level, wavelet_name );
        
        % Get horizontal, vertical and diagonal coefficients using the
        % wavelet and the decomposition level 5.
        [H1,V1,D1] = detcoef2( 'all', decomp_vector, S, 5 );
        
        % Get approximate coefficients from wavelet and the decomposition
        % of level 5.
        A1 = appcoef2(decomp_vector,S,'bior3.5',5);
        
        % Get image of the coefficients from level 5 decomposed image.
        V1img = wcodemat(V1,255,'mat',5);
        H1img = wcodemat(H1,255,'mat',5);
        D1img = wcodemat(D1,255,'mat',5);
        A1img = wcodemat(A1,255,'mat',5);
        
        % Display the coefficient images. 
        figure;
        imagesc(V1img);
        figure;
        imagesc(H1img);
        figure;
        imagesc(D1img);
        figure;
        imagesc(A1img);
        figure;
        
        % Get inverse 2D DWT of level 5 decomposed image and display it.
        out = idwt2( A1,H1,V1,D1,'bior3.5' );
        figure;
        imagesc(out);
        
        % Get a 2D level dependent threshold using the penalhi method.
        threshold1          = wthrmngr( 'dw2ddenoLVL', 'penalhi', decomp_vector, S, 5 );

        % set threshold type as Soft Threshold
        sorh                = 's';
        
        % Get a denoised image using the above threshold of type Soft.
        [im_ws_s, CXC, LXC]   = wdencmp( 'lvd', decomp_vector, S, ...
                                wavelet_name, decomposition_level, threshold1, sorh );
                  
        % set threshold type as Hard Threshold          
        sorh                = 'h';
        
        % Get a denoised image using the above threshold of type Hard.
        [im_ws_h, CXC, LXC]   = wdencmp( 'lvd', decomp_vector, S, ...
                                wavelet_name, decomposition_level, threshold1, sorh );
        
        % Display original input image.
        figure;
        imshow(im); colormap gray; axis off;
        title('Original Image');

        % Display noisy image.
        figure;
        imshow(im_noise); colormap gray; axis off;
        title('Noise introduced Image');
        
        % Display local averaged image.
        figure;
        imshow(im_lclavg_fltrd); colormap gray; axis off;
        title('Gaussian Blur filtering');
        
        % Display median filtered image.
        figure;
        imshow(im_median_fltrd); colormap gray; axis off;
        title('Median filtering');
        
        % Display wavelet denoised using hard threshold image
        figure;
        
        % Convert to uint8 format.
        im_ws_h_norm        = im_ws_h - min(im_ws_h(:));
        im_ws_h_norm        = im_ws_h_norm ./ max(im_ws_h_norm(:));
        im_ws_h             = im2uint8( im_ws_h_norm );
        imshow(im_ws_h); colormap gray; axis off;
        title('Wavelet Shrinkage using a hard threshold');
        
        % Display wavelet denoised using soft threshold image
        figure;
        
        % Convert to uint8 format.
        im_ws_s_norm        = im_ws_s - min(im_ws_s(:));
        im_ws_s_norm        = im_ws_s_norm ./ max(im_ws_s_norm(:));
        im_ws_s             = im2uint8( im_ws_s_norm );
        imshow(im_ws_s); colormap gray; axis off;
        title('Wavelet Shrinkage using a soft threshold');
        
        % Show surface of noisy image.
        figure;
        mesh(im_noise);
        
        % Show surface of soft thresholded image.
        figure;
        mesh(im_ws_s);
        
        % Calculate mean square errors of the output images.
        im_mse_med          = immse( im, im_median_fltrd );
        im_mse_lclavg       = immse( im, im_lclavg_fltrd );
        im_mse_ws_h         = immse( im, im_ws_h );
        im_mse_ws_s         = immse( im, im_ws_s );
        
        % Display the MSEs in console.
        disp( im_mse_med );format long g;
        disp( im_mse_lclavg );format long g;
        disp( im_mse_ws_h );format long g;
        disp( im_mse_ws_s );format long g;
        
    % If the input image is a Color image.
    else
        
        % Get the Red, Green, and Blue channels.
        im_r                = im(:,:,1);
        im_g                = im(:,:,2);
        im_b                = im(:,:,3);
        
        % Introduce noise in all 3 channels.
        im_noise_r          = imnoise( im_r, 'gaussian', 0, 0.03 );
        im_noise_g          = imnoise( im_g, 'gaussian', 0, 0.03 );
        im_noise_b          = imnoise( im_b, 'gaussian', 0, 0.03 );
        
        % Merge all 3 channels to 1 3D image matrix again.
        im_noise            = im;
        im_noise(:,:,1)     = im_noise_r;
        im_noise(:,:,2)     = im_noise_g;
        im_noise(:,:,3)     = im_noise_b;
        
        % Do median filtering on the noisy image.
        im_median_fltrd         = im;
        im_median_fltrd(:,:,1)  = medfilt2( im_noise_r );
        im_median_fltrd(:,:,2)  = medfilt2( im_noise_g );
        im_median_fltrd(:,:,3)  = medfilt2( im_noise_b );
        
        % Do local averaging on the noisy image.
        fltr                    = fspecial( 'gaussian', 3, 5 ); 
        im_lclavg_fltrd         = im;
        im_lclavg_fltrd(:,:,1)  = imfilter( im_noise_r, fltr, 'same', 'repl' );
        im_lclavg_fltrd(:,:,2)  = imfilter( im_noise_g, fltr, 'same', 'repl' );
        im_lclavg_fltrd(:,:,3)  = imfilter( im_noise_b, fltr, 'same', 'repl' );

        % Define a wavelet variable that uses a Bi-orthogonal wavelet with
        % 5 vanishing levels and 3 reconstruction levels.
        wavelet_name        = 'bior3.5';
        
        % Number of decomposition levels
        decomposition_level = 5;
        
        % Do wavelet decomposition after converting the noisy image to
        % Bi-orthogonal wavelet domain and get the decomposition
        % vector.
        [decomp_vector_r, S_r]  = wavedec2( im_noise_r, decomposition_level, wavelet_name );
        [decomp_vector_g, S_g]  = wavedec2( im_noise_g, decomposition_level, wavelet_name );
        [decomp_vector_b, S_b]  = wavedec2( im_noise_b, decomposition_level, wavelet_name );
        
        % Get a 2D level dependent threshold using the penalhi method.
        threshold_r          = wthrmngr( 'dw2ddenoLVL', 'penalhi', decomp_vector_r, S_r, 3);
        threshold_g          = wthrmngr( 'dw2ddenoLVL', 'penalhi', decomp_vector_g, S_g, 3);
        threshold_b          = wthrmngr( 'dw2ddenoLVL', 'penalhi', decomp_vector_b, S_b, 3);

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
        figure;
        imshow(im); colormap gray; axis off;
        title('Original Image');

        % Display noisy image.
        figure;
        imshow(im_noise); colormap gray; axis off;
        title('Noise introduced Image');

        % Display Local averaged image.
        figure;
        imshow(im_lclavg_fltrd); colormap gray; axis off;
        title('Gaussian Blur filtering');
        
        % Display Median filtered image.
        figure;
        imshow(im_median_fltrd); colormap gray; axis off;
        title('Median filtering');
        
        % Display image with hard threshold denoising.
        figure;
        imshow(im_ws_h); colormap gray; axis off;
        title('Wavelet Shrinkage using a hard threshold');
        
        % Display image with soft threshold denoising.
        figure;
        imshow(im_ws_s); colormap gray; axis off;
        title('Wavelet Shrinkage using a soft threshold');
    end
end