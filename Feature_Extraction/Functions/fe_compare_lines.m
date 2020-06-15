function [arr_region_data, arr_regions, num_regions, num_merge_regions, arr_merge_regions] = fe_compare_lines(arr_line_prev, arr_line, num_prev, num_line)
% input: 
% arr_line_prev: 
%       array containing start, end and tag of each range in the
%       previous row
% -arr_line:
%       the first column is weighted sum of x values, the second is sum of
%       weights, the third is number of pixels, the fourth and fifth are the
%       start and end pixels for each range
% -num_prev:
%       the number of ranges in the previous line
% -num_line
%       the number of ranges in the current line
% returns:
% -arr_region_data: 
%       the first column is the weighted sum of x values, the second
%       is the sum of weights, the third is the number of pixels
%       for each region tag, with the tag being the index in this array and
%       the fourth is the row in which it is stored for merging in
%       arr_merge_regions
% -arr_regions:
%       one dimensional array containing the regions that ranges in the
%       current row have been tagged with
% -num_regions:
%       number of regions ranges in the new row have been tagged with
% -arr_merge_regions:
%       array containing region tags in the final array to be merged, with
%       each row containing tags corresponding to a connected region, the
%       first element indicates the number of tags
% -num_merge_regions:
%       number of nonempty rows in arr_merge_regions

    % loading constants
    load("constants_feature_extraction_3.mat", "NUM_REGIONS_LINE", "NUM_MERGE_LINE", "NUM_TAGS_MERGE");
    % initializing variables and arrays
    counter_int = 1;
    num_regions = 0;
    num_merge_regions = 0;
    arr_region_data = zeros(NUM_REGIONS, 4);
    arr_regions = zeros(NUM_REGIONS, 1);
    arr_merge_regions = zeros(NUM_MERGE_LINE, NUM_TAGS_MERGE);
    
    % looping over the ranges in the current row
    for i_range = 1:num_line
        [start_range, end_range] = arr_line(i_range, 4:5);
        match_flag = 0;
        
        % looping over the remaining ranges in the previous row
        for counter_int = counter_int:num_prev
            [start_prev, end_prev] = arr_line_prev(counter_int, 2:3);
            
            % break and store the tag if one intersecting range is found
            if fe_compare_ranges(start_range, end_range, start_prev, end_prev)
                tag_prev = arr_line_prev(counter_int, 1);
                match_flag = 1;
                break
            end
        end
        
        % store data to the corresponding tag, find other intersecting
        % ranges
        if match_flag ==1
            
            % store the data in the tag of the first region
            if arr_region_data(tag_prev, 3) == 0
                num_regions = num_regions+1;
                arr_regions(num_regions) = tag_prev;
            end
            arr_region_data(tag_prev, 1:3) = arr_region_data(tag_prev, 1:3) + arr_line(i_range, 1:3);
            
            % find regions that intersect
            for counter_int = (counter_int+1):num_prev
                
                % break if the next range in the previous row does not
                % intersect, and set the tag of the last intersecting range
                % in the previous row to the tag of the current range
                if not(fe_compare_ranges(start_range, end_range, arr_line_prev(counter_int, 2), arr_line_prev(counter_int, 3)))
                    counter_int = counter_int-1; %#ok<FXSET>
                    arr_line_prev(counter_int, 1) = tag_prev;
                    break
                end
                
                % sequence to be followed if the next row intersects but 
                % does not share the same tag as the first intersecting range
                if arr_line_prev(counter_int, 1) ~= tag_prev
                    tag_new = arr_line_prev(counter_int, 1);
                    
                    
                    if arr_region_data(tag_prev, 4) == 0
                        if arr_region_data(tag_new, 4) == 0
                        % if both the previous tag and the current tag
                        % haven't been merged with another tag
                            num_merge_regions = num_merge_regions +1;
                            arr_merge_regions(num_merge_regions, 1) = 2;
                            arr_merge_regions(num_merge_regions, 2:3) = [tag_prev, tag_new];
                        
                        % if the new tag has been merged before but not the
                        % first one
                        else
                            merge_row = arr_region_data(tag_new, 4);
                            arr_merge_regions(merge_row, 1) = arr_merge_regions(merge_row, 1) +1;
                            arr_merge_regions(merge_row, arr_merge_regions(merge_row, 1)+1) = tag_prev;
                            arr_region_data(tag_prev, 4) = merge_row;
                        end
                    else
                        
                        % if the first tag has been merged but not the
                        % new one
                        if arr_region_data(tag_new, 4) == 0
                            merge_row = arr_region_data(tag_prev, 4);
                            arr_merge_regions(merge_row, 1) = arr_merge_regions(merge_row, 1) +1;
                            arr_merge_regions(merge_row, arr_merge_regions(merge_row, 1)+1) = tag_new;
                            arr_region_data(tag_new, 4) = merge_row;
                        else
                            
                            % if both the new and the first tags have been
                            % merged but with separate regions
                            if arr_region_data(tag_new, 4) ~= arr_region_data(tag_prev, 4)
                                merge_row_to = arr_region_data(tag_prev, 4);
                                merge_row_from = arr_region_data(tag_new, 4);
                                num_offset  = arr_merge_regions(merge_row_to, 1)+1;
                                num_move = arr_merge_regions(merge_row_from, 1);
                                arr_merge_regions(merge_row_to, num_offset+1:num_offset + num_move+1) = arr_merge_regions(merge_row_from, 2:num_move+1);
                                arr_merge_regions(merge_row_from, :) = 0;
                            end
                        end
                    end
                end
            end
        end
    end
end