function [out] = OFDM_estimate_CFO(parameters, rx_buffer, pilot_interval_index)

     sampling_frequency = parameters.fft_size * parameters.subcarrier_spacing;
     sampling_period= sampling_frequency^-1;
     
     phase_est = angle(sum(rx_buffer(pilot_interval_index(1)) .* conj(rx_buffer(pilot_interval_index(2)))));
     f_est = phase_est / (64*2*pi*sampling_period); % 2pi*f_est(Hz)
     n_bits = length(rx_buffer);

     comp_phase = exp(1j*f_est*2*pi*[1:n_bits]*sampling_period);
     rx_buffer = rx_buffer .* comp_phase'; 

     out = rx_buffer;

end