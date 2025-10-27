% Description : Plots line at the event times on a figure. 
%
% Algorithm : 
%
% Input :  
% events  - A list of events. If the provided matrix contains 2 columns, the
% events are considered periods with the first column the starting times
% of the periods and the second column the end times. In that case, the
% beginning of the period is plotted with a thicker line.
% handle - A handle for the figure to be modified. (default : gcf)
% color - the color of the lines. (default : red)
%
% Output : 
%
% Author : Nikolas Karalis
% Date : 08/06/2013
%
% Dependencies : fillcurve, jplot
%
% Updates : 
% 13/10/2015: Added the functionality to plot the period as a
% semi-transparent surface on top of the figure. For this, the argument
% 'all' has to be passed for yposition and in that case, the thickness
% should be between 0 and 1 (default: 0.1), 0 being completely transparent 
% and 1 being solid.
% 24/01/2015: Fixed a bug in the case of plotting only two line events
% 17/06/2013 : Added functionality for horizontal lines for the periods
% (default). Input arguments are changed.
%
% Copyright (C) 2013  Nikolas Karalis
% 
% ********************************************************************
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% ********************************************************************
%
function plot_events(events, color,thickness, yposition, handle)

if nargin<5 || isempty(handle)
    handle = gcf;
end;

if nargin<2 || isempty(color)
    color = [255,0,0,0.5];
end;
if nargin<4 || isempty(yposition)
    yposition = NaN;
elseif strcmp(yposition,'min') && ~isvector(events)
    yposition = min(get(gca,'Ylim'));
    if nargin<3 || isempty(thickness); 
        thickness = 15; 
    end
    
elseif strcmp(yposition,'max') && ~isvector(events)
    yposition = max(get(gca,'Ylim'));
    
elseif strcmp(yposition,'all') && ~isvector(events)
    yposition1 = min(get(gca,'Ylim'));
    yposition2 = max(get(gca,'Ylim'));
end;
if nargin<3 || isempty(thickness)
    thickness = 2;
end;
figure = handle;    

if  ~isempty(events) 
    hold on;
    if isvector(events) % Normal vertical lines
        events = events(:);
        line([events events]',get(gca,'ylim'),'Color',color,'LineWidth',thickness);
        line()
    else
        if ~isnan(yposition); % Normal period events
            if strcmp(yposition,'all')
                if thickness>1 || thickness<0; thickness = 0.1; end; % make sure is inside the bounds
                for c=1:size(events,1);                
                    if verLessThan('matlab','8.4')
                        fillcurve([events(c,1),(events(c,2)+events(c,1))],[yposition1 yposition1], [yposition2  yposition2],color,color,thickness); 
                    else
                        area([events(c,1),(events(c,2)+events(c,1))],[yposition2 yposition2], yposition1, 'FaceColor',color,'EdgeColor','none','FaceAlpha',thickness,'EdgeAlpha',thickness)
                    end
                end
            else
                jplot([events(:,1) (events(:,2) + events(:,1))],[yposition yposition],'Color',color,'LineWidth',thickness);
                %plot([events(:,1) (events(:,2) + events(:,1))],[yposition yposition],'Color',color,'LineWidth',thickness);
            end
            
        else % For different thickness of vertical lines at beginning and end of period
            line([events(:,1) (events(:,2) + events(:,1))]',get(gca,'ylim'),'Color',color,'LineWidth',thickness);
            line([events(:,1) (events(:,2) + events(:,1))]',get(gca,'ylim'),'Color',color,'LineWidth',thickness-1,'LineStyle','-');
        end;
    end
    hold off;

end;