function [segmented_img,pixel_labels,nuclei_idx] = segment(img)
    % convert rgb image to hsv color space
    lab_img = rgb2lab(img);
    % isolate the colors from lab by taking only ab
    ab_img = lab_img(:,:,2:3);
    rows = size(ab_img,1);
    col = size(ab_img,2);
    % reshape matrix into a nx2 matrix
    ab_img = reshape(ab_img,rows*col,2);
    % k hyperparameter to adjust the number of clusters
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
    segmented_img = segmented_images{nuclei_idx};
end