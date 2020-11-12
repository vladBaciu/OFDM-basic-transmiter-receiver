function [f_est, out_ach_bits] = OFDM_estimate_CFO_preamble(long_preamble, fs)

Ts = 1/fs;

compare = long_preamble;
long_preamble(33:64) = [];
preamble_1 = long_preamble(1:length(long_preamble)/2);
preamble_2 = long_preamble(1+(length(long_preamble)/2):end);
phase_est = angle(sum(preamble_1 .* conj(preamble_2)));
f_est = phase_est / (length(long_preamble)*2*pi*Ts); % 2pi*f_est(Hz)

end