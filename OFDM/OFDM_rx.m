function [rx_data] = OFDM_rx(parameters,timeDomain_data)
    
    rx_buffer = zeros(parameters.number_subcarriers, parameters.number_symbols);
    cyclicPrefix_length = round(parameters.fft_size/16);
    symbol_length = parameters.fft_size + cyclicPrefix_length;
    
    for k = 0: parameters.number_symbols-1
        timeDomain_symbol = timeDomain_data(symbol_length*k + 1: symbol_length*(k+1));
        timeDomain_without_cp = timeDomain_data(cyclicPrefix_length+1:end);
        %time to domain frequency
        frequency_symbols = fft(timeDomain_without_cp);
            
        rx_out = zeros(parameters.number_subcarriers, 1);
        rx_out(1:parameters.number_subcarriers/2) = frequency_symbols(end - parameters.number_subcarriers/2 + 1:end);
        rx_out(parameters.number_subcarriers/2+1:end) = frequency_symbols(2:parameters.number_subcarriers/2+1);
        rx_buffer(:,k+1) = rx_out;
    end
    rx_data=rx_buffer;
end