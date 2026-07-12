# Contributing to the ModDef device registry

Thanks for adding or improving a device profile.

## Public domain (CC0)

Device profiles here are dedicated to the public domain under CC0-1.0. By
contributing, you dedicate your contribution to the public domain under the
same terms. There is no Contributor License Agreement.

## Developer Certificate of Origin

Every commit must carry a `Signed-off-by` trailer certifying that you have the
right to submit the change. This is the
[Developer Certificate of Origin](https://developercertificate.org/) 1.1.
Commit with `-s`:

```bash
git commit -s -m "Your message"
```

A DCO check runs on each pull request.

## Profile guidelines

- Cite the register map source in a comment at the top of the profile (vendor
  document, reverse-engineering notes, or hardware testing).
- Run `./validate.sh`; it lints every profile against the ModDef rules.
- Keep offsets 0-based, the ModDef convention, rather than 1-based Modicon
  addresses.
