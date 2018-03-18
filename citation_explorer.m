function link_table = citation_explorer(orig_string,varargin)
% citation_explorer Explore citations and references at multiple depths
%
% This function uses Europe PubMed Central to extract references or
% citations from a given paper and recursively find reference/citations
% within those. The relevant papers at each level can be crudely assessed by
% counting how many times they appear.
% The first argument is a search string for the initial paper, the title
% generally works well.
% Other arguments use name-value pairs and are :
%   - 'searchtype': Cell of strings, default is {'reference' 'citation'}.
%   This input is used to indicate the search direction at each level of
%   the recursion. Use 'reference' to search the references in all
%   papers at a given level. Use 'citation' to search which papers cited
%   all papers at a given level. The first element indicates the search
%   done on the initial paper. The default value thus searches all
%   references in the initial paper, and then all the articles citing each
%   of the references. This combination is useful to search for relevant
%   recent papers on the same topic. Only two levels are recommended for
%   most cases: 3 levels leads to a very large amount of searches as there
%   are no optimizations yet.
%   - 'disp': Integer, default is 30. This parameter indicates how many of
%   the found papers at the final level should be displayed, ordered in
%   descending order of number of appearances in the level. The output is
%   in the for n_appearances / n_citations : Author (year) title. With the
%   default 'searchtype', the first paper in the list should be the
%   original paper.
%
% The function returns a table containing metadata about all the retrieved
% papers. The field link_id stores the ID of the paper that linked to the paper (this 
% could be useful for constructing graphs afterwards. The field level indicates at
% which level of the recursion the paper was retrieved.
%
% Example use: 
%    out = citation_explorer('What makes a reach movement effortful',...
%    'searchtype',{'reference' 'citation'},...
%    'disp',30);

p=inputParser;
addParameter(p,'searchtype',{'reference' 'citation'});
addParameter(p,'disp',30);
parse(p,varargin{:});



orig_search = webread(['https://www.ebi.ac.uk/europepmc/webservices/rest/search?query="' orig_string '"&format=json']);
orig_result = orig_search.resultList.result;

if iscell(orig_result)
    orig_result = orig_result{1};
end


orig_result

opts = weboptions;
opts.Timeout = 5;
opts.UserAgent = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_5; fr-fr) AppleWebKit/525.18 (KHTML, like Gecko) Version/3.1.2 Safari/525.20.1';


searchtype = p.Results.searchtype;


link_cell = cell(length(searchtype)+1,1);

link_cell{1}{1} = orig_result;
link_cell{1}{1}.link_id = 'NaN';
link_cell{1}{1}.level = 0;
link_cell{1}{1}.search_type = 'NA';

for sid = 1:length(searchtype)
    fprintf('\n')
    disp(['level ' num2str(sid) ' ' searchtype{sid}])
    link_cell{sid+1} = cell(length(link_cell{sid}),1);
    for k = 1:length(link_cell{sid})
        if mod(k,100)==0
            fprintf('\n')
            disp([num2str(k) ' / ' num2str(length(link_cell{sid}))])
        end
        temp = link_cell{sid}{k};
        if isfield(temp,'id')
            
            %Do the actual search if we have a pmid
            try
                temp_references= webread(['https://www.ebi.ac.uk/europepmc/webservices/rest/MED/'...
                    temp.id ...
                    '/' searchtype{sid} 's/1/200/json'],opts);
            catch
                %disp('Likely timeout')
                fprintf('o')
                temp_references.hitCount = 0;
            end
            
            
            if isstruct(temp_references) && temp_references.hitCount>0
                %extract search results if any
                ref_list = temp_references.([ searchtype{sid} 'List' ]).(searchtype{sid});
                
                %Cell is the most universal output so we convert to that if
                %needed
                if ~iscell(ref_list)
                    %if numel(ref_list)>1 %output was probably an array of structs
                    link_cell{sid+1}{k} = cell(numel(ref_list),1);
                    for l = 1:numel(ref_list)
                        link_cell{sid+1}{k}{l} = ref_list(l);
                    end
                    %                 else    % output was a single struct
                    %                     output_cell{k}= {ref_list};
                    %                 end
                else
                    link_cell{sid+1}{k} = ref_list;
                end
                
                %add metadata about origin of reference
                for l = 1:length(link_cell{sid+1}{k})
                    link_cell{sid+1}{k}{l}.link_id = temp.id;
                    link_cell{sid+1}{k}{l}.level = sid;
                    link_cell{sid+1}{k}{l}.search_type = searchtype{sid};
                end
                fprintf('.')
            else
                disp(['No ' searchtype{sid}  ' for: ' temp.title])
                fprintf('x')
            end
            
        else
            if isfield(temp,'tite')
                disp(['No id for: ' temp.title])
            end
            if isfield(temp,'publicationTitle')
                disp(['No id for: ' temp.publicationTitle])
            end
        end
    end
    link_cell{sid+1}=vertcat(link_cell{sid+1}{:});
end

%% Get results out of the cell of structs and into a table for output
%For this we use a subset of fields

clear temp
n = sum(cellfun('length',link_cell));
fields = {'title' 'id' 'authorString' 'pubYear' 'link_id' 'level' 'search_type' 'citedByCount'}; 
temp.title = repmat({''},n,1);
temp.id = repmat({''},n,1);
temp.authorString = repmat({''},n,1);
temp.pubYear= repmat({''},n,1);
temp.link_id = repmat({''},n,1);
temp.level= nan(n,1);
temp.citedByCount= nan(n,1);
temp.search_type= repmat({''},n,1);
temp.valid = true(n,1);

ind = 1;
for sid = 1:length(searchtype)+1
    for k = 1:length(link_cell{sid})
        for f = 1:length(fields)
            if isfield(link_cell{sid}{k},fields{f})
                if iscell(temp.(fields{f}))
                    temp.(fields{f}){ind} = link_cell{sid}{k}.(fields{f});
                else
                    temp.(fields{f})(ind) = link_cell{sid}{k}.(fields{f});
                end
            end
        end
        ind = ind+1;
    end
end

link_table = struct2table(temp);
link_table = link_table(link_table.valid,:);

%% Do the display if asked


if p.Results.disp>0
    sel = link_table.level==max(link_table.level);
    
    to_disp = rowfun(@(a,b,c,d)deal(a(1),b(1),c(1),d(1)),link_table(sel,:),'GroupingVariables','id',...
        'inputVariables',{'authorString' 'pubYear' 'title' 'citedByCount'},...
        'outputVariableName',{'authorString' 'pubYear' 'title' 'citedByCount'});
    
    to_disp = sortrows(to_disp,'GroupCount','descend');
    
    for k = 1:min(p.Results.disp, height(to_disp))
        disp([num2str(to_disp.GroupCount(k)) ' / ' num2str(to_disp.citedByCount(k)) ' : ' to_disp.authorString{k}(1:min(40,length(to_disp.authorString{k}))) ' (' num2str(to_disp.pubYear{k}) ') ' to_disp.title{k}])
    end
end

