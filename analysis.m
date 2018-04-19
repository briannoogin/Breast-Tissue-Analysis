
for image_idx = 4:4
    img_name = 'b_1_';
    img_num = num2str(image_idx);
    jpg = '.jpg';
    filePath = strcat('images/',img_name,img_num,jpg);
    img = imread(filePath);
    rows = size(img,1);
    col = size(img,2);
    % segment the nuceli 
    [segmented,pixel_labels,nuclei_idx] = segment(img);
    lab_segmented = rgb2lab(segmented);
    % isolate the l dimension from the nuceli
    l_dim = lab_segmented(:,:,1);
    % find where are the potential nuceli in the image and in the L
    % dimension
    blue_index = nuclei_idx == pixel_labels;
    l_nuceli = l_dim(blue_index == 1);
    % use otsu's method to threshold the image into two binary classes
    light_mask = imbinarize(l_nuceli);
    nuclei_labels = repmat(uint8(0),[rows,col]);
    nuclei_labels(blue_index(light_mask == false)) = 1;
    % expand nuclei_labels to the other two dimensions
    nuclei_labels = repmat(nuclei_labels,[1 1 3]);
    nuclei_image = segmented;
    % isolate non-nuclei 
    nuclei_image(nuclei_labels ~= 0) = 0;
    newFilePath = strcat('output/',img_name,img_num,'nuclei_isolated',jpg);
    % this imwrite is for k-means segmented images
    %imwrite(segmented_images{nuclei_idx},newFilePath);
    % this imwrite is for nuceli
    %imwrite(nuclei_image,newFilePath);
    imshow([nuclei_image,segmented]);
end
