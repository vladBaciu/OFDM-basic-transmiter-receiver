function [t_est, out_ach_bits] = SISO_estimate_STO(ach_bits, flags)
%SISO_estimate_STO 
%   intputs:
%       -ach_bits: the bit seires coming out from the transmitter
%       -flags:
%   outputs:
%       -t_est: [N_sub] preamble in frequency domain
%       -out_ach_bits: the bit stream after sync with the STO

len_bits = length(ach_bits);
arr_shift = [-2*flags.N_subcarr: 2*flags.N_subcarr];

% calculate the auto-correlation
len_arr_shift = length(arr_shift);
arr_corr = zeros(1, len_arr_shift);
for ii=1:len_arr_shift
    cur_shift = arr_shift(ii);
    ach_bits = ach_bits';
    ach_bits_shift = circshift(ach_bits, cur_shift);
    ach_bits = ach_bits';
    preamble1 = ach_bits_shift(1:flags.N_subcarr);
    preamble2 = ach_bits_shift(flags.N_subcarr+1:flags.N_subcarr*2);
    arr_corr(ii) = sum(preamble1 .* conj(preamble2));
end

arr_corr_ma = movmean(arr_corr, flags.N_averageWindow);
[~,ind_] = max(abs(arr_corr_ma));
t_est = -(arr_shift(ind_)) - flags.N_averageWindow/2 - flags.N_cp;

% draw the figure of time shift estimation
% figure(2)
% plot(arr_shift,abs(arr_corr_ma))

% compensate the STO
out_ach_bits = ach_bits.';
out_ach_bits = circshift(out_ach_bits, -t_est);
out_ach_bits = out_ach_bits.';

end

