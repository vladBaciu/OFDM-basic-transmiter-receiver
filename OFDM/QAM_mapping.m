function [out] = QAM_mapping(modulation)
    
    modulation_type = {'QPSK','16QAM','64QAM'};
    constellaton_points_list = [4 16 64];
    
    
    modulation_index = find(strcmp(modulation_type, modulation));
    constellaton_points=constellaton_points_list(modulation_index);
    
    %create complex data d=I+jQ
    I_channel = -(sqrt(constellaton_points)-1):2:(sqrt(constellaton_points)-1);
    Q_channel = flip(I_channel);
    index = 1;
    for k=1:length(I_channel)
        for j=1:length(Q_channel)
            qam_alphabet(index) = I_channel(k) + 1j*Q_channel(j);
            index=index+1;
        end
    end
    
    out = qam_alphabet(:);
%     figure
%     plot(out, 'o')
%     title('TX Constellations') 
end