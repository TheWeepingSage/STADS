function [num_prev, arr_prev_row] = fe_line2prev(arr_row_data, num_ranges, arr_regions,  arr_merge_regions, arr_region_data)
%{
input:
-arr_line:
    array containing data (corresponding to the current row)
    to be converted to the previous row data format
-num_line:
    number of rows in arr_line
-arr_regions:
    array containing the region corresponding to each row in arr_line
-arr_region_flags:
    array containing flags corresponding to each region, 0 if they have
    none
-arr_merge_regions:
    array containing the merge information for the regions with flags

output:
-arr_line_prev:
    array containing the data of the row in the required format
%}
    arr_prev_row = zeros(num_ranges, 3);
    if num_ranges>0
        for i_convert = 1:num_ranges
            region = arr_regions(i_convert);
            % if the region is to be merged, change the tag to the one it is to
            % be merged into
            region_flag = arr_region_data(region, 4);
            if region_flag
                region = arr_merge_regions(region_flag, 2);
            end
            % add tags and start and end values to the final array
            arr_prev_row(i_convert, 1) = region;
            arr_prev_row(i_convert, 2:3) = arr_row_data(i_convert, 4:5);
        end
        num_prev = num_ranges;
    else
        num_prev = 0;
        arr_prev_row = [];
    end
end