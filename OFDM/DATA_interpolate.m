function [H_interpolated] = DATA_interpolate(H,pilot_loc,n_subcarriers,method)
% Input: H = Channel estimate using pilot sequence
% pilot_loc = Location of pilot sequence
% n_subcarriers = no of subcarriers size
% method = ’linear’/’spline’
% Output: H_interpolated = interpolated channel
if pilot_loc(1)>1
slope = (H(2)-H_est(1))/(pilot_loc(2)-pilot_loc(1));
H = [H(1)-slope*(pilot_loc(1)-1) H]; pilot_loc = [1 pilot_loc];
end
if pilot_loc(end) <n_subcarriers
slope = (H(end)-H(end-1))/(pilot_loc(end)-pilot_loc(end-1));
H = [H H(end)+slope*(n_subcarriers-pilot_loc(end))];
pilot_loc = [pilot_loc n_subcarriers];
end
if lower(method(1))=='l'
    H_interpolated=interp1(pilot_loc,H,(1:n_subcarriers));
else H_interpolated = interp1(pilot_loc,H,(1:n_subcarriers),'spline');
end