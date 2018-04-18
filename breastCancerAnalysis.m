
for image_idx = 4:4
    img_name = 'b_1_';
    img_num = num2str(image_idx);
    jpg = '.jpg';
    filePath = strcat('images/',img_name,img_num,jpg);
    img = imread(filePath);
    % convert rgb image to hsv color space
    lab_img = rgb2lab(img);
    % isolate the colors from lab by taking only ab
    ab_img = lab_img(:,:,2:3);
    rows = size(ab_img,1);
    col = size(ab_img,2);
    % reshape matrix into a nx2 matrix
    ab_img = reshape(ab_img,rows*col,2);
    % specify hyper parameter
    k = 3;
    [cluster_idx, cluster_center] = kmeans(ab_img,k,'distance','sqEuclidean','Replicates',3);
    % reshape back to orignal shape
    pixel_labels = reshape(cluster_idx,rows,col);
    segmented_images = cell(1,3);
    % copy the pixel category to the other two dimensions 
    rgb_label = repmat(pixel_labels,[1 1 3]);
    % isolate each cluster
    for k_index = 1:k
        color = img;
        color(rgb_label ~= k_index) = 0;
        segmented_images{k_index} = color;
    end
    % the nuclei have the smallest average of ab values
    mean_cluster_value = mean(cluster_center,2);
    [~,idx] = sort(mean_cluster_value);
    nuclei_idx = idx(1);
    lab_segmented = rgb2lab(segmented_images{nuclei_idx});
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
    nuclei_image = segmented_images{nuclei_idx};
    % isolate non-nuclei 
    nuclei_image(nuclei_labels ~= 0) = 0;
    newFilePath = strcat('output/',img_name,img_num,'nuclei_isolated',jpg);
    % this imwrite is for k-means segmented images
    %imwrite(segmented_images{nuclei_idx},newFilePath);
    % this imwrite is for nuceli
    %imwrite(nuclei_image,newFilePath);
    imshow([nuclei_image,segmented_images{nuclei_idx}]);
end
