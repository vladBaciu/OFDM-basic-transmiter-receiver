function [out] = OFDM_estimate_CFO(parameters, rx_buffer, pilot_interval_index)

     sampling_frequency = parameters.fft_size * parameters.subcarrier_spacing;
     sampling_period= sampling_frequency^-1;
     phase_est = 0;
     for k=1:parameters.number_symbols;
        for i=1:length(pilot_interval_index)-1
            phase_est = phase_est + angle(rx_buffer(pilot_interval_index(i),k) .* conj(rx_buffer(pilot_interval_index(i+1),k)));
        end
     end

     phase_est = phase_est/(length(pilot_interval_index) * parameters.number_symbols);
     f_est = phase_est / (parameters.number_symbols*(pilot_interval_index(2) - pilot_interval_index(1))*2*pi*sampling_period); % 2pi*f_est(Hz)

     n_bits = length(rx_buffer);

     comp_phase = exp(1j*f_est*2*pi*[1:n_bits]*sampling_period);
     rx_buffer = rx_buffer .* comp_phase'; 

     out = rx_buffer;

end