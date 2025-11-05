import { Context } from "aws-lambda";

type RootEvent = {
  input: Array<string>;
};

export const handler = async (event: RootEvent, context: Context) => {
  console.log(event);
  return JSON.stringify({
    message: `Together Adam and Cole say '${event.input.join(" ")}'!!`,
  });
};
