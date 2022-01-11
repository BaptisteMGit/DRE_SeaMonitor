function resizeBehavior(~, ~, fixed_W, fixed_H, W_handles, H_handles)

% global fig;

%Save all figure childrens in the variable h (handle structure)
h = allchild(gcf);

%Get the Position of the current window
F = get(gcf,'Position');

% %Get the Positions of the current figure childrens
% P=get(h,'position'); %if there are more than one child
% if(iscell(P))
%     P=cell2mat(P);
%     [number_of_GUI_Elements, ~]=size(P);
%     for i=1:number_of_GUI_Elements
%         W_pixel=W_handles(i)*fixed_W;
%         H_pixel=H_handles(i)*fixed_H;
%         
%         W_norm=W_pixel/F(3);
%         H_norm=H_pixel/F(4);
%         
%         set(h(i),'Position',[P(i,1),P(i,2),P(i,3),H_norm])  %keep fixed only the height
%         %set(h,'Position',[P(i,1),P(i,2),W_norm,P(i,4)])    %keep fixed only the width
%         %set(h,'Position',[P(i,1),P(i,2),W_norm,H_norm])    %keep fixed both
%     end
% else %if there's only one child
%     if(~isempty(P))
%         W=0.9; H=0.05;
%         W_pixel=W*fixed_W;
%         H_pixel=H*fixed_H;
%         
%         W_norm=W_pixel/F(3);
%         H_norm=H_pixel/F(4);
%         
%         set(h,'Position',[P(1),P(2),P(3),H_norm])           %keep fixed only the height
%         %set(h,'Position',[P(1),P(2),W_norm,P(4)])          %keep fixed only the width
%         %set(h,'Position',[P(1),P(2),W_norm,H_norm])        %keep fixed both
%     end
% end

end