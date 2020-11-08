%% Frequency compensation - Boya
function [r_symbol_sp] = OFDM_phase_tracking(N_subcarr,len_p,pilot_channel,r_symbol_sp,parameters)
% Phase tracking based on pilot sub-carriers
%   intputs:
%       -N_subcarr: number of sub carriers
%       -len_p: pilot length
%       -pilot_channel:
%       -r_symbol_sp: received separated symbol

%   outputs:
%       -r_symbol_sp: compensated separated symbol

pilot_shift = 0;
    for ii=1:len_p
        cur_symbol = r_symbol_sp(:,ii);
        % extract the pilot and estimate the CFO
        for ii2=1:length(pilot_channel)
            cur_shift = angle(cur_symbol(pilot_channel(ii2)));
            pilot_shift = pilot_shift + cur_shift;
        end
        pilot_shift = (pilot_shift/length(pilot_channel)) - angle(parameters.pilot_frequency);
        
        % correct the CFO using the pilot estimation
        cur_symbol = cur_symbol * exp(-1j*pilot_shift);
        r_symbol_sp(:,ii) = cur_symbol;
    end
end