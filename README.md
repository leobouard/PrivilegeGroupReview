# PrivilegeGroupReview

This script retrieves Active Directory (AD) groups managed by specific users and sends an email to the managers with the details of their respective groups.

## Parameters

- `SearchBase` (Mandatory): The AD path where the search for groups begins.
- `SearchScope` (Optional): The scope of the search. It can be 'Base', 'OneLevel', or 'Subtree'. The default is 'Subtree'.
- `TestRecipient` (Optional): An array of email addresses for testing the script.

## How it works

1. The script retrieves all AD groups in the specified `SearchBase` and `SearchScope` that have a `ManagedBy` attribute.
2. It sorts the managers of these groups and retrieves their email addresses.
3. The script reads an HTML template from the `body.html` file in the script's directory.
4. For each manager, the script retrieves the groups they manage and the members of these groups. It then appends this information to the HTML body.
5. If the HTML body contains group information, the script sends an email to the manager with the group details. If the `TestRecipient` parameter is specified, the email is sent to the test recipients instead.

## Usage

You can run the script in a scheduled task. Make sure to replace the parameters with your actual values.

```powershell
./PrivilegeGroupReview.ps1 -SearchBase "your_search_base" -SearchScope "your_search_scope" -TestRecipient "test_recipient1", "test_recipient2"
```

## Preview

![Preview of the table](/preview.png)