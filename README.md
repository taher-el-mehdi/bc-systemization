# Systemization

Systemization is a Business Central extension that helps you add structured custom fields to tables and pages without writing AL code by hand.

In simple terms, it lets you:

- define new fields you want to store,
- choose where those fields should appear on Business Central pages,
- generate a ready-to-install `.app` file,
- download it, or publish it directly from the setup screen.

## Who This Is For

Systemization is designed for:

- functional consultants,
- administrators,
- solution partners,
- power users who understand Business Central setup,
- teams who want to reduce small development requests.

You do **not** need to understand AL development in order to use the main setup pages.

## What You Can Do

### 1. Create a custom extension setup

You can create a new Systemization record with:

- app name,
- publisher,
- version,
- description,
- object start id.

Each setup also gets a unique internal identifier automatically.

### 2. Add new fields to Business Central tables

You can choose a target table and define new fields such as:

- field number,
- field name,
- caption,
- data type,
- length,
- option values.

This is useful when you want to store extra business data in a structured way.

### 3. Add fields to Business Central pages

You can choose a target page and define which fields should be shown there.

For each page field, you can control:

- which field should appear,
- where it should be placed,
- which control it should be placed next to,
- the source expression used by the page.

This helps you surface new information exactly where users need it.

### 4. Control field placement on pages

For page fields, you can choose placement behavior such as:

- `addafter`
- `addbefore`

You can also choose the anchor control, so the new field appears in the right location on the page.

### 5. Generate the extension package

Once your setup is complete, Systemization can generate the required extension content and build a final `.app` package.

The app package includes the generated extension structure needed for Business Central deployment.

### 6. Download or publish directly

From the main extension card, users can:

- **Download App** to save the generated package,
- **Publish App** to send it directly for deployment.

When publishing starts, a notification gives access to the deployment status.

## Main Features

- Create table extension definitions from setup pages.
- Create page extension definitions from setup pages.
- Define custom field metadata without manual coding.
- Place fields on pages using anchor-based placement.
- Generate package artifacts automatically.
- Build a final `.app` package.
- Download the package from Business Central.
- Publish the package from Business Central.
- Reuse the extension setup identifier as package identity in the build flow.
- Manage setup through linked card and list pages.

## Typical Business Use Cases

### Add a customer-specific field

Example: you want to add a new field like **Customer Segment Note** to a business table and later show it on a page.

Systemization lets you define the field, generate the extension, and make it available without building the whole feature manually in AL.

### Show extra information on an existing page

Example: you already have data available and want to place it on a sales or customer page near an existing control.

Systemization lets you choose the page, choose the anchor, and place the new field before or after that control.

### Reduce small development tickets

Many business changes are small:

- one extra field,
- one extra page control,
- one adjusted page layout.

Systemization helps handle these recurring requests faster.

## How a User Works With It

### Step 1: Create a Systemization extension

Open **Systemization Extensions** and create a new record.

Fill in:

- App Name
- Publisher
- Version
- Description
- Object Start Id

### Step 2: Add table fields

Choose **Add Field in Table**.

Then:

1. choose the target table,
2. enter the table extension object id,
3. add one or more field definitions,
4. choose field type and other details.

### Step 3: Add page fields

Choose **Add Field in Page**.

Then:

1. choose the target page,
2. enter the page extension object id,
3. add one or more page field lines,
4. choose the placement type,
5. choose the anchor control,
6. confirm the source expression.

### Step 4: Generate the app

When setup is ready:

- choose **Download App** to get the `.app` file, or
- choose **Publish App** to start deployment.

## Supported Field Types

Systemization currently supports these field types:

- Text
- Code
- Integer
- Decimal
- Boolean
- Date
- DateTime
- Option

## Supported Page Placement Types

- addafter
- addbefore

## Important Notes

- Object ids should stay in your allowed customer/partner range.
- Table and page extension object ids are validated and must be above the enforced minimum.
- Each configured table should contain at least one field.
- Each configured page should contain at least one page field.

## Troubleshooting

### Nothing is generated

Make sure you have configured at least one table extension or one page extension.

### A table or page is missing child lines

Make sure the related fields or page fields have been created before generating the app.

### Publish does not complete

Use the deployment status action from the notification and verify environment permissions.

### The generated layout is not where you expected

Check the selected:

- placement type,
- anchor control,
- target page.

## Permissions

Use permission set `50312 "Systemization perm"` to grant access to the Systemization objects.

## Technical Reference

For advanced users, the current setup model is:

- `Systemization Extension` → `Systemization Table` → `Systemization Field`
- `Systemization Extension` → `Systemization Page` → `Systemization Page Field`

The generation flow is handled by `codeunit 50308 "Systemization Orchestrator"`.

The current app targets:

- Business Central 27+
- Runtime 16+
- Cloud deployment

## License

This project uses the MIT License.

[MIT License](License.txt)