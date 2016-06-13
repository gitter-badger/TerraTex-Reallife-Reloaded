local faq = {}

function loadFAQ()
    local query = "SELECT * FROM faq LEFT JOIN faq_kat ON faq_kat.ID = faq.katID ORDER BY faq_kat.Order";
    local runQuery = dbQuery(MySql._connection, query);
    local result = dbPoll(runQuery, -1);

        local rules = {}
    local katCounter = 0
    local katIDs = {}

    for theKey, dasatz in ipairs(result) do
        -- Antwort Frage kat
        local tmpTable = {}
        local tmpID = katCounter + 1
        if (katIDs[dasatz["kat"]]) then
            tmpID = katIDs[dasatz["kat"]]
        else
            katIDs[dasatz["kat"]] = tmpID
            faq[tmpID] = {
                ["title"] = dasatz["kat"],
                ["rules"] = {},
            }
            katCounter = katCounter + 1
        end

        tmpTable = {
            ["text"] = dasatz["Frage"],
            ["answer"] = dasatz["Antwort"]
        }

        table.insert(faq[tmpID]["rules"], tmpTable)
    end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), loadFAQ)

addEvent("sendMeFAQ", true)
function sendMeFAQ_func()
    triggerClientEvent(source, "addFAQ", source, faq)
end
addEventHandler("sendMeFAQ", getRootElement(), sendMeFAQ_func)
