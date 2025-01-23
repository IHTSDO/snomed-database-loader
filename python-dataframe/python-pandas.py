import csv
import pandas as pd

if __name__ == '__main__':
    path = 'Snapshot/Terminology/sct2_Description_Snapshot-en_INT_20230731.txt'

    # full reference: https://pandas.pydata.org/docs/reference/api/pandas.read_csv.html
    df = pd.read_csv(
        path
        , sep="\t"                          # the file is tab separated
        , encoding='utf-8'
        # -----------------------------------
        # IMPORTANT
        , quoting=csv.QUOTE_NONE            # else we loose quotes in descriptions, because 0 or csv.QUOTE_MINIMAL is the default. (csv.QUOTE_NONE=3)
        , keep_default_na=False             # fields contains n.a. / n/a / none, which are read as null without this setting.
        # -----------------------------------
        , parse_dates=["effectiveTime"]     # if needed, we can directly cast these columns as dates (as list, so multiple columns are possible)
        , date_format="%Y%m%d"              #   we have do specify the date format, for the param above
    )

    print(len(df))

